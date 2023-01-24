#!/bin/bash -i
#
# Простая автоматическая установка Pritunl
#

set -u

#Простенький обработчик ошибок
abort() {
  printf "%s\n" "$@" >&2
  exit 1
}

#Установщик homebrew
homebrew_install ()
{
 
 echo "Введите пароль от устройства и нажмите Enter. Пароль в консоли не 
видно"
 sudo echo "Установка Homebrew началась. Это займет некоторое время..." 
 NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
 
 if [[ "$?" != "0" ]] 
 then 
  abort "Произошла ошибка во время установки Homebrew"
 fi
 echo "Homebrew успешно установлен!"
}

#Установщшик wireguard
wireguard_install ()
{
 echo "Установка Wireguard началась."
 $HMBR_PREFIX/bin/brew install wireguard-tools > /dev/null
 if [[ "$?" != "0" ]]
 then 
  abort "Произошла ошибка во время установки Wireguard"
 fi
 echo "Wireguard успешно установлен!"
 NEED_RESTART=1

}

pritunl_install ()
{
  echo "Установка Pritunl началась"
  $HMBR_PREFIX/bin/brew install --cask pritunl > /dev/null
  if [[ "$?" != "0" ]]
  then
    abort "Произошла ошибка во время установки Pritunl"
  fi
  echo "Pritunl успешно установлен!"
}



#Check root
#if [[ $(whoami) != "root" ]]
#then 
#  abort "Запустите скрипт в режиме суперпользователя (sudo) или добавьте учетной записи ${USER} необходимые права"
#else
#  echo "Все необходимые права присутствуют, продолжаем..." 
#fi

#Определим архитектуру
CHKARCH="$(/usr/bin/uname -m)"

if [[ "${CHKARCH}" == "arm64" ]]
then
  HMBR_PREFIX="/opt/homebrew"
  echo "Mac на чипе Apple. Архитектура arm64..."
else  
  HMBR_PREFIX="/usr/local"
  echo "Mac на процессоре Intel. Архитектура x86_64..."
fi

#Проверим, установлен ли Homebrew
find $HMBR_PREFIX/bin/brew 2>&1 > /dev/null
if [[ $? != "0" ]] 
then
  homebrew_install
else
  echo "Homebrew уже установлен. Переходим к следующему шагу..."
fi

#Чекаем Wireguard
NEED_RESTART=0
$HMBR_PREFIX/bin/brew list | grep wireguard-tools > /dev/null
if [[ $? != "0" ]]
then
  wireguard_install
else
  echo "Wireguard уже установлен. Переходим к следующему шагу..."
fi

#Чекаем притунл
$HMBR_PREFIX/bin/brew list | grep pritunl > /dev/null
if [[ $? != "0" ]]
then
  pritunl_install
else
  echo "Pritunl уже установлен. Переходим к следующему шагу..."
fi
   
#Если ставили wg - нужен ребут
if [[ "$NEED_RESTART" = "1" ]]
then
  echo "Mac будет перезагружен. Закройте все нужные приложения и нажмите ENTER"
  read
  sudo shutdown -r now
else
  echo "Перезагрузка не требуется. Всего доброго и хорошего настроения!"
fi
