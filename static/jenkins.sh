#!/bin/sh

DESC="Jenkins CI Server"
NAME=Jenkins

RUN_AS=jenkins
JENKINS_HOME=/var/lib/jenkins
JENKINS_OPTS=
PIDFILE=$JENKINS_HOME/$NAME.pid

JENKINS_PATH=/opt/jenkins/jenkins.war
JAVA=java
JAVA_OPTS=-Xmx512m

case "$1" in
  start)
    if [ -f $PIDFILE ]
    then
      echo "$NAME already running"
    else
      echo "Starting $DESC: $NAME"
      su -p -s /bin/sh $RUN_AS -c "
      cd $JENKINS_HOME
      JENKINS_HOME=$JENKINS_HOME
      exec $JAVA $JAVA_OPTS -jar $JENKINS_PATH $JENKINS_OPTS  \
        $JENKINS_OPTS                                           \
        </dev/null >>$JENKINS_HOME/console_log 2>&1 &
      echo \$! >$PIDFILE
      "
    fi
    ;;
  stop)
    if [ -f $PIDFILE ]
    then
      echo "Stopping $DESC: $NAME"
      echo -n "kill " 
      cat $PIDFILE
      kill -15 `cat $PIDFILE | awk '{print $1}'`
      RETVAL=$?
      [ $RETVAL = 0 ] && rm -f $PIDFILE
    else
      echo "$NAME not running"
    fi
    ;;
  restart)
    echo "Restarting $DESC: $NAME"
    $0 stop 
    sleep 1
    $0 start
    ;;
  force)
    rm -f $PIDFILE
    sleep 1
    $0 start
    ;;
  status)
    if [ -f $PIDFILE ]
    then
      echo -n "$NAME running at PID "
      cat $PIDFILE
    else
      echo "$NAME not running"
    fi
    ;;
  *)
    echo "usage: $NAME {start|stop|restart|force}"
    exit 1
    ;;
esac
exit 0
