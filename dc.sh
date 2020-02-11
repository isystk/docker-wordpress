#! /bin/bash

pushd ./docker

MYSQL_CLIENT=$(dirname $0)/mysql/scripts
PATH=$PATH:$MYSQL_CLIENT

function usage {
    cat <<EOF
$(basename ${0}) is a tool for ...

Usage:
  $(basename ${0}) [command] [<options>]

Options:
  stats|st          Dockerコンテナの状態を表示します。
  init              初期化します。（データベース・ログ）
  start             すべてのDaemonを起動します。
  stop              すべてのDaemonを停止します。
  mysql login       MySQLにログインします。
  --version, -v     バージョンを表示します。
  --help, -h        ヘルプを表示します。
EOF
}

function version {
    echo "$(basename ${0}) version 0.0.1 "
}

case ${1} in
    stats|st)
        docker container stats
    ;;

    init)
        # 停止＆削除（コンテナ・イメージ・ボリューム）
        docker-compose down --rmi all --volumes
        rm -Rf ./mysql/data/*
        rm -Rf ./mysql/logs/*
        rm -Rf ./apache/logs/*
        rm -Rf ./php/logs/*
        rm -Rf ../public/wp-config.php
        docker network create frontend
        docker network create backend
    ;;

    start)
        docker-compose up -d
    ;;
    
    stop)
        docker-compose down
    ;;

    mysql)
      case ${2} in
          login)
              mysql -u root -ppassword -h 127.0.0.1  
          ;;
          dump)
              mysqldump -u root -ppassword -h 127.0.0.1 -A > ./mysql/init/dump.sql
          ;;
          *)
              usage
          ;;
      esac
    ;;
    
    help|--help|-h)
        usage
    ;;

    version|--version|-v)
        version
    ;;
    
    *)
        echo "[ERROR] Invalid subcommand '${1}'"
        usage
        exit 1
    ;;
esac


