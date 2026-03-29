///usr/bin/env jbang "$0" "$@" ; exit $?
//DEPS info.picocli:picocli:4.6.3

import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;

import java.awt.Desktop;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.concurrent.Callable;
import java.util.stream.Stream;

@Command(name = "set_aws_profile", mixinStandardHelpOptions = true, version = "set_aws_profile 0.1",
        description = "Select AWS profile (fzf), SSO login, optional EKS kubeconfig; emit zsh exports on stdout.")
class set_aws_profile implements Callable<Integer> {

    @Option(names = {"-s", "--set-only"}, description = "Only set AWS_PROFILE (no SSO / EKS) for SSO profiles")
    boolean setOnly;

    private static final long THREE_HOURS_MS = 3L * 60 * 60 * 1000;

    private record ProfileRow(String display, String awsProfile, String cluster, String region) {}

    private static final ProfileRow[] PROFILES = {
            new ProfileRow("LIVEDATA_IGP_NONPROD", "LIVEDATA_IGP_NONPROD", "nonprod-euc1-igp-srld-io", "eu-central-1"),
            new ProfileRow("LIVEDATA_IGP_PROD_OBSERVER", "LIVEDATA_IGP_PROD_OBSERVER", "prod-euc1-igp-srld-io", "eu-central-1"),
            new ProfileRow("LIVEDATA_IGP_PROD_DEVELOPER", "LIVEDATA_IGP_PROD_DEVELOPER", "prod-euc1-igp-srld-io", "eu-central-1"),
            new ProfileRow("NO_TRD_LIVEDATA_K8S_NONPROD", "NO_TRD_LIVEDATA_K8S_NONPROD", "nonprod-euc1-srlivedata-io", "eu-central-1"),
            new ProfileRow("NO_TRD_LIVEDATA_SHARED_NONPROD", "NO_TRD_LIVEDATA_SHARED_NONPROD", "nonprod-euc1-srlivedata-io", "eu-central-1"),
            new ProfileRow("NO_TRD_LIVEDATA_K8S_PROD", "NO_TRD_LIVEDATA_K8S_PROD", "prod-euc1-srlivedata-io", "eu-central-1"),
            new ProfileRow("priv", "priv", "", ""),
    };

    public static void main(String... args) {
        int exitCode = new CommandLine(new set_aws_profile()).execute(args);
        System.exit(exitCode);
    }

    @Override
    public Integer call() throws Exception {
        Path home = Path.of(System.getenv().getOrDefault("HOME", ""));
        if (!Files.isDirectory(home)) {
            err("HOME is not set or not a directory.");
            return 1;
        }

        String selected = runFzf();
        if (selected == null || selected.isBlank()) {
            err("Cancelled.");
            return 0;
        }

        ProfileRow row = null;
        for (ProfileRow p : PROFILES) {
            if (p.display.equals(selected)) {
                row = p;
                break;
            }
        }
        if (row == null) {
            err("Unknown selection: " + selected);
            return 1;
        }

        if ("priv".equals(row.awsProfile)) {
            PrivCreds creds = parsePrivProfile(home.resolve(".aws/config"));
            if (creds == null || creds.accessKeyId == null || creds.secretAccessKey == null) {
                err("Could not read [profile priv] from ~/.aws/config (need aws_access_key_id, aws_secret_access_key).");
                return 1;
            }
            String region = creds.region != null ? creds.region : "eu-central-1";
            outExport("AWS_PROFILE", "priv");
            outExport("AWS_ACCESS_KEY_ID", creds.accessKeyId);
            outExport("AWS_SECRET_ACCESS_KEY", creds.secretAccessKey);
            outExport("AWS_DEFAULT_REGION", region);
            writeProfileFile(home, "priv");
            return 0;
        }

        String region = row.region != null && !row.region.isEmpty() ? row.region : "eu-central-1";
        if (setOnly) {
            err("AWS_PROFILE set to " + row.awsProfile);
            outExport("AWS_PROFILE", row.awsProfile);
            writeProfileFile(home, row.awsProfile);
            return 0;
        }

        boolean validToken = hasRecentCliCacheJson(home.resolve(".aws/cli/cache"));
        String envProfile = System.getenv("AWS_PROFILE");

        boolean needSso;
        if (Objects.equals(envProfile, row.awsProfile)) {
            if (!validToken) {
                err("Token expired, refreshing login...");
                needSso = true;
            } else {
                err("Already logged in with valid token for " + row.awsProfile);
                writeProfileFile(home, row.awsProfile);
                return 0;
            }
        } else {
            err("Switching to profile " + row.awsProfile);
            needSso = true;
        }

        if (needSso) {
            int code = ssoLoginWithAutoOpen(row.awsProfile);
            if (code != 0) {
                return code;
            }
        }

        outExport("AWS_PROFILE", row.awsProfile);
        outUnset("AWS_ACCESS_KEY_ID");
        outUnset("AWS_SECRET_ACCESS_KEY");
        outUnset("AWS_DEFAULT_REGION");

        if (row.cluster != null && !row.cluster.isEmpty()) {
            int eks = runInheritIo(List.of("aws", "eks", "update-kubeconfig", "--region", region, "--name", row.cluster));
            if (eks != 0) {
                return eks;
            }
        }

        writeProfileFile(home, row.awsProfile);
        return 0;
    }

    private static void err(String msg) {
        System.err.println(msg);
    }

    /** zsh-safe single-quoted string */
    private static String shSingleQuote(String s) {
        return "'" + s.replace("'", "'\"'\"'") + "'";
    }

    private static void outExport(String name, String value) {
        System.out.println("export " + name + "=" + shSingleQuote(value));
    }

    private static void outUnset(String name) {
        System.out.println("unset " + name);
    }

    private static void writeProfileFile(Path home, String profileName) throws IOException {
        Path dir = home.resolve(".aws");
        Files.createDirectories(dir);
        Files.writeString(dir.resolve("aws_profile"), profileName + "\n", StandardCharsets.UTF_8);
    }

    private static String runFzf() throws IOException, InterruptedException {
        ProcessBuilder pb = new ProcessBuilder(
                "fzf", "--height", "20%", "--reverse", "--prompt=Select AWS profile: ");
        pb.redirectError(ProcessBuilder.Redirect.INHERIT);
        pb.redirectInput(ProcessBuilder.Redirect.PIPE);
        pb.redirectOutput(ProcessBuilder.Redirect.PIPE);
        Process p = pb.start();
        try (Writer w = new OutputStreamWriter(p.getOutputStream(), StandardCharsets.UTF_8)) {
            for (ProfileRow pr : PROFILES) {
                w.write(pr.display);
                w.write('\n');
            }
        }
        String line;
        try (BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream(), StandardCharsets.UTF_8))) {
            line = r.readLine();
        }
        int code = p.waitFor();
        if (code != 0 && (line == null || line.isBlank())) {
            return null;
        }
        return line != null ? line.trim() : null;
    }

    private static boolean hasRecentCliCacheJson(Path cacheDir) throws IOException {
        if (!Files.isDirectory(cacheDir)) {
            return false;
        }
        long cutoff = System.currentTimeMillis() - THREE_HOURS_MS;
        try (Stream<Path> walk = Files.walk(cacheDir, 4)) {
            return walk
                    .filter(Files::isRegularFile)
                    .filter(path -> path.getFileName().toString().toLowerCase(Locale.ROOT).endsWith(".json"))
                    .anyMatch(path -> {
                        try {
                            return Files.getLastModifiedTime(path).toMillis() >= cutoff;
                        } catch (IOException e) {
                            return false;
                        }
                    });
        }
    }

    private static int ssoLoginWithAutoOpen(String profile) throws IOException, InterruptedException {
        ProcessBuilder pb = new ProcessBuilder("aws", "sso", "login", "--no-browser", "--profile", profile);
        pb.redirectErrorStream(true);
        Process p = pb.start();
        try (BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = r.readLine()) != null) {
                err(line);
                String t = line.trim();
                if (t.startsWith("https://")) {
                    openUrl(t);
                }
            }
        }
        return p.waitFor();
    }

    private static void openUrl(String url) {
        try {
            URI uri = URI.create(url);
            if (Desktop.isDesktopSupported()) {
                Desktop d = Desktop.getDesktop();
                if (d.isSupported(Desktop.Action.BROWSE)) {
                    d.browse(uri);
                    return;
                }
            }
        } catch (Exception ignored) {
            // fall through to CLI
        }
        String os = System.getProperty("os.name", "").toLowerCase(Locale.ROOT);
        try {
            if (os.contains("mac")) {
                new ProcessBuilder("open", url).inheritIO().start().waitFor();
            } else {
                new ProcessBuilder("xdg-open", url).inheritIO().start().waitFor();
            }
        } catch (Exception e) {
            err("URL: " + url);
        }
    }

    private static int runInheritIo(List<String> command) throws IOException, InterruptedException {
        ProcessBuilder pb = new ProcessBuilder(command);
        pb.inheritIO();
        Process p = pb.start();
        return p.waitFor();
    }

    private record PrivCreds(String accessKeyId, String secretAccessKey, String region) {}

    private static PrivCreds parsePrivProfile(Path configFile) throws IOException {
        if (!Files.isRegularFile(configFile)) {
            return null;
        }
        List<String> lines = Files.readAllLines(configFile, StandardCharsets.UTF_8);
        boolean inPriv = false;
        String accessKey = null;
        String secretKey = null;
        String region = null;
        for (String raw : lines) {
            String line = raw.trim();
            if (line.startsWith("[") && line.endsWith("]")) {
                String inner = line.substring(1, line.length() - 1).trim();
                inPriv = inner.equals("profile priv") || inner.equals("priv");
                continue;
            }
            if (!inPriv || line.isEmpty() || line.startsWith("#") || line.startsWith(";")) {
                continue;
            }
            int eq = line.indexOf('=');
            if (eq < 0) {
                continue;
            }
            String key = line.substring(0, eq).trim().toLowerCase(Locale.ROOT);
            String val = line.substring(eq + 1).trim();
            switch (key) {
                case "aws_access_key_id" -> accessKey = val;
                case "aws_secret_access_key" -> secretKey = val;
                case "region" -> region = val;
                default -> { }
            }
        }
        return new PrivCreds(accessKey, secretKey, region);
    }
}
