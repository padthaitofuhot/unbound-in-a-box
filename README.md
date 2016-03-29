# Unbound-in-a-Box
A [shipit](https://github.com/padthaitofuhot/shipit)-ized Unbound DNS caching resolver container for whatever needs doing.

# How?
```
$ git clone https://github.com/padthaitofuhot/unbound-in-a-box
$ cd unbound-in-a-box
$ sudo ./shipit.sh
```

# What's in the box?
* The Unbound DNS Resolver
* Resolves from the root (root.hints fetched from Internic by default)
* Full DNSSEC support
    * Pulls DNSSEC root key from ICANN
    * Hardens DNSSEC and glue records by default
* Listens on port 5353 by default (customizable in conf.yml); expects dnsmasq-in-a-box in front of it.
