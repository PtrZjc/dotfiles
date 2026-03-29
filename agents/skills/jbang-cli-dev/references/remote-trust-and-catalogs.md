# Remote scripts, trust, catalogs, aliases

## Running from a URL

JBang can run `.java` sources, JARs, or WARs from HTTPS, GitHub/GitLab/Bitbucket file links, gists, etc.:

```bash
jbang https://github.com/org/repo/blob/main/script.java
jbang https://gist.github.com/user/id
```

First run from an untrusted origin prompts for trust. **`jbang trust add <prefix>`** whitelists a URL prefix; **`jbang trust list`**, **`jbang trust remove`**.

Use **`jbang --insecure`** only when you understand the risk (TLS verification relaxed).

## Aliases and catalogs

- **Alias**: `jbang hello@jbangdev` resolves via catalog configuration.
- **Catalogs**: `jbang catalog add|list|remove|update` manage JSON catalogs of aliases.
- **Publishing**: see JBang docs for app catalogs and sharing (`jbang-catalog.json`).

Script metadata `//DESCRIPTION` and `//DOCS` improve discoverability in catalog and `jbang info` flows.
