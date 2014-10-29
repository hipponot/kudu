#!/bin/bash
### BEGIN INIT INFO
# Provides:          APPLICATION
# Required-Start:    $all
# Required-Stop:     $network $local_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start the APPLICATION unicorns at boot
# Description:       Enable APPLICATION at boot time.
### END INIT INFO
# 
# Use this as a basis for your own Unicorn init script.
# Change APPLICATION to match your app.
# Make sure that all paths are correct.
 
set -e
 
# Change these to match your app:
APP_NAME=<%=project_name%>
APP_VERSION=<%=project_version%>

if [ -n "$SUDO_USER" ]
then
 RUN_AS=$SUDO_USER
else 
 RUN_AS=$USER
fi

APP_ROOT=/home/$RUN_AS/.rvm/gems/$RUBY_VERSION@$APP_NAME-$APP_VERSION/gems/$APP_NAME-$APP_VERSION
PID="/tmp/unicorn/pids/<%=project_name%>-<%=project_version%>/unicorn.pid"

if [ -n "$RACK_ENV" ]
then
  ENV=$RACK_ENV
else
  ENV=development
fi

RVM_HOME="/home/$RUN_AS/.rvm/gems/$RUBY_VERSION"
GEM_HOME="/home/$RUN_AS/.rvm/gems/$RUBY_VERSION@<%=project_name%>-<%=project_version%>"
GEM_PATH="/home/$RUN_AS/.rvm/gems/$RUBY_VERSION@<%=project_name%>-<%=project_version%>:/home/$RUN_AS/.rvm/gems/$RUBY_VERSION@global"
UNICORN_OPTS="-D -E $ENV -c $APP_ROOT/config/unicorn.rb"
SET_PATH="cd $APP_ROOT; export GEM_HOME=$GEM_HOME; export GEM_PATH=$GEM_PATH"
UNICORN_LOG_DIR="/var/log/unicorn/<%=project_name%>-<%=project_version%>"
if [ ! -d $UNICORN_LOG_DIR ]; then
  mkdir -p $UNICORN_LOG_DIR
  chown $RUN_AS:$RUN_AS $UNICORN_LOG_DIR
fi

<%if with_sidekiq%> 
SIDEKIQ_START_CMD="$SET_PATH;god load $APP_ROOT/config/sidekiq.god"
SIDEKIQ_STOP_CMD="$SET_PATH;god stop <%=project_name%>-<%=project_version%>"
SIDEKIQ_RESTART_CMD="$SET_PATH;god restart <%=project_name%>-<%=project_version%>"
<%end%>

CMD="$SET_PATH;$RVM_HOME@global/bin/unicorn $UNICORN_OPTS deploy.ru"
old_pid="$PID.oldbin"
 
cd $APP_ROOT || exit 1
 
sig () {
  test -s "$PID" && kill -$1 `cat $PID`
}
 
oldsig () {
  test -s $old_pid && kill -$1 `cat $old_pid`
}
 
case ${1-help} in
start)
  <%if with_sidekiq%> 
  sudo su - $RUN_AS -c "$SIDEKIQ_START_CMD" && echo $SIDEKIQ_START_CMD
  <%end%>
  sig 0 && echo >&2 "Already running" && exit 0
  sudo su - $RUN_AS -c "$CMD"
  ;;
stop)
  <%if with_sidekiq%> 
  sudo su - $RUN_AS -c "$SIDEKIQ_STOP_CMD" && echo $SIDEKIQ_STOP_CMD
  <%end%>
  sig QUIT && exit 0
  echo >&2 "Not running"
  ;;
force-stop)
  sig TERM && exit 0
  echo >&2 "Not running"
  ;;
restart|reload)
  <%if with_sidekiq%> 
  sudo su - $RUN_AS -c "$SIDEKIQ_RESTART_CMD" && echo $SIDEKIQ_RESTART_CMD
  <%end%>
  sig HUP && echo reloaded OK 
  echo >&2 "Couldn't reload, starting '$CMD' instead"
  sudo su - $RUN_AS -c "$CMD"
  ;;
upgrade)
  sig USR2 && exit 0
  echo >&2 "Couldn't upgrade, starting '$CMD' instead"
  sudo su - $RUN_AS -c "$CMD"
  ;;
rotate)
  sig USR1 && echo rotated logs OK && exit 0
  echo >&2 "Couldn't rotate logs" && exit 1
  ;;
*)
  echo >&2 "Usage: $0 <start|stop|restart|upgrade|rotate|force-stop>"
  exit 1
  ;;
esac
