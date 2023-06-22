#!/usr/bin/env bash

# define the file list
src_dst_pairs=(
    common/zshrc            .zshrc
    kerberos/krb5.conf      .kerberos/krb5.conf
    ssh/config              .ssh/config
    bin/krbtools-keytab     bin/krbtools-keytab
    bin/vnctools-config     bin/vnctools-config
    bin/vnctools-kill       bin/vnctools-kill
    bin/vnctools-list       bin/vnctools-list
    bin/vnctools-new        bin/vnctools-new
    bin/vnctools-open       bin/vnctools-open
    bin/vnctools-opts       bin/vnctools-opts
    vnctools/vnctools-fasic-beast1-2694x1440.cfg    .vnctools/vnctools-fasic-beast1-2694x1440.cfg
    vnctools/vnctools-fasic-beast2-2694x1440.cfg    .vnctools/vnctools-fasic-beast2-2694x1440.cfg
)

# initialize the flags and parse the command line arguments
flag_dry_run=false
flag_trace=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            flag_dry_run=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done


# execute the script
echo "Starting Script..."
echo
(
    set -ex

    case $flag_dry_run in
        true)   cmd='echo';;
        false)  cmd='';;
        *) echo "Error with dry-run option"; exit 1;;
    esac


    # backup all the files
    echo "Backing up files..."
    backup_path=`$cmd mktemp -d`
    for (( i=0; i<${#src_dst_pairs[@]} ; i+=2  )) ; do
        target="${src_dst_pairs[i+2]}"
        src=~/$target
        dst=${backup_path}/${target}

        if [[ -f ${src} ]]; then
            $cmd mkdir -p $(dirname $src) && $cmd touch $src
            $cmd mkdir -p $(dirname $dst) && $cmd touch $dst
            $cmd cp $src ${dst}
        fi
    done
    $cmd find ${backup_path}
    echo

    # update the files
    for (( i=0; i<${#src_dst_pairs[@]} ; i+=2  )) ; do
        src="${src_dst_pairs[i+1]}"
        dst="${src_dst_pairs[i+2]}"
        $cmd ln -sf `realpath $src` ~/$dst
    done

    $cmd find ${backup_path} -type f
)