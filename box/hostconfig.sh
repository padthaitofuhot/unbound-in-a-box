#@IgnoreInspection BashAddShebang

verbose "Trying to fetch root hints from Internic..."
if ! curl -fsSL https://www.internic.net/domain/named.cache >${box_home}/named.cache 2>&1 | log; then
    warn "Couldn't fetch root.hints right now, you'll have to do it manually. Check shipit.log for details."
    warn "The command for doing this yourself is:"
    warn "curl -fsSL https://www.internic.net/domain/named.cache > ${box_home}/named.cache"
fi

verbose "Trying to fetch icannbundle.pem from IANA..."
if ! curl -fsSL http://data.iana.org/root-anchors/icannbundle.pem >${box_home}/icannbundle.pem 2>&1 | log; then
    warn "Couldn't fetch icannbundle.pem right now, you'll have to do it manually. Check shipit.log for details."
    warn "The command for doing this yourself is:"
    warn "curl -fsSL http://data.iana.org/root-anchors/icannbundle.pem > ${box_home}/icannbundle.pem"
fi

verbose "Adding custom_configs.conf"
cp box/custom_configs.conf "${box_home}/conf.d/"
