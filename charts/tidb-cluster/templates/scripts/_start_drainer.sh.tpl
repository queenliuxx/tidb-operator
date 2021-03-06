set -euo pipefail

domain=`echo ${HOSTNAME}`.{{ .Values.clusterName }}-drainer

elapseTime=0
period=1
threshold=30
while true; do
    sleep ${period}
    elapseTime=$(( elapseTime+period ))

    if [[ ${elapseTime} -ge ${threshold} ]]
    then
        echo "waiting for drainer domain ready timeout" >&2
        exit 1
    fi

    if nslookup ${domain} 2>/dev/null
    then
        echo "nslookup domain ${domain} success"
        break
    else
        echo "nslookup domain ${domain} failed" >&2
    fi
done

/drainer \
-L={{ .Values.binlog.drainer.logLevel | default "info" }} \
-addr=`echo ${HOSTNAME}`.{{ .Values.clusterName }}-drainer:8249 \
-config=/etc/drainer/drainer.toml \
-disable-detect={{ .Values.binlog.drainer.disableDetect | default false }} \
-initial-commit-ts={{ .Values.binlog.drainer.initialCommitTs | default 0 }} \
-log-file=
