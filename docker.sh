#!/usr/bin/env bash

# ────  cores ──────

normal=$'\e[0m'                                                   
C=$(printf '\033')
vermelho="${C}[1;31m"
green="${C}[1;32m"
yellow="${C}[1;33m"
B="${C}[1;34m"
LG="${C}[1;37m" 
DG="${C}[1;90m" 
sem_cor="${C}[0m"
UNDERLINED="${C}[4m"
EX="${C}[48;5;1m"
RED="${C}[1;31m"                                                                                              
 # ────  cores ──────  


echo -e """ \033[5;37m 
  march0s1as         __       __
                     '.'--.--'.-'
       .,_------.___,   \' r'
       ', '-._a      '-' .'
        '.    '-'Y \._  /
          '--;____'--.'-,
           /..'       ''' 
           \033[0m """

echo "${normal}[${green}+${normal}] Enumerating the container."
echo ""
# -- começando a putaria kk --
enumeration(){

echo "${yellow} -- NETWORK  --"
# ────  ID DO CONTAINER ──────

container_id=$(hostname)
echo "${normal}[${green}+${normal}]${green} CONTAINER ID ${normal}---> "${container_id}

# ────  IP DO CONTAINER ──────

container_ip=$(ip route get 1 | head -1 | cut -d' ' -f7)
echo "${normal}[${green}+${normal}] ${green}CONTAINER IP ${normal}---> "${container_ip}

# ────  GATEWAY PADRÃO ──────

gateway=$(ip route get 1 | cut -d' ' -f 3)
echo "${normal}[${green}+${normal}]${green} GATEWAY IP ${normal}  ---> "${gateway}


# ────  BÍNÁRIOS DO DOCKER (ctr e docker) ──────

echo "${yellow} -- BINARIES  --"
bin_docker=$(which docker)
echo "${normal}[${green}+${normal}]${green} DOCKER BINARY ${normal}-----> "${bin_docker}
bin_ctr=$(which ctr)
echo "${normal}[${green}+${normal}] ${green}CTR BINARY ${normal}--------> "${bin_ctr}

# ────  INFORMAÇÕES ADICIONAIS ──────

echo "${yellow} -- INFORMATIONS  -- ${normal}"
cpu_info=$(grep 'model name' /proc/cpuinfo | head -n1 | cut -d':' -f2| cut -d' ' -f2-)
kernel_container=$(uname -r)
arch=$(uname -m)
usuario=$(whoami)

# ────  VERIFICAR OS GRUPOS ──────

perigo_grupos="docker\|lxd\|root\|sudo\|wheel"
groups=$(groups| sed -e "s/\($perigo_grupos\)/${UNDERLINED}${vermelho}&${sem_cor}${LG}/g")

# ────  VERIFICAR VERSÃO DO DOCKER ──────

if [ -x "$(command -v docker)" ]; then
    dockerver=$(docker --version)
    echo "${normal}[${green}+${normal}] ${green}[DOCKER VERSION] ${normal}------->" ${dockerver}       
else
    echo "${normal}[${green}+${normal}] ${green}[DOCKER VERSION] ${normal}------->" ${DG}DOCKER BINARY NOT FOUND =[ $normal
fi

# ────  CAPABILITIES ──────
verificar(){
    capshEXISTE=$(which capsh 2>/dev/null)

    if [ -x "$(command -v $capshEXISTE)" ]; then
        echo "${yellow} -- CAPABILITIES  -- $normal"
        cap_perigosos="cap_sys_admin\|cap_sys_ptrace\|cap_sys_module\|dac_read_search\|dac_override"
        capsh --print |grep 'cap_' | cut -d ' ' -f 3- | tr -d '=' | sed "s/\($cap_perigosos\)/${UNDERLINED}${vermelho}&${sem_cor}/g"            
    else
        echo "${yellow} -- CAPABILITIES  -- ${normal}"
        echo "${DG}CAPSH BINARY NOT FOUND =[ $normal"
    fi

}

# ────  SUID ──────

suid(){
    findEXISTE=$(which find 2>/dev/null)
    suidCOMANDO=$(find / -perm -u=s -type f 2>/dev/null)

    echo "${yellow} -- SUID  -- ${normal}"
    if [ -x "$(command -v $findEXISTE)" ]; then
        suid_perigosos="nano\|vi \|vim\|systemctl\|find\|python\|python3\|apt\|apt-get\|ash\|bash\|sysctl\|cat\|cp\|mv"
        echo $suidCOMANDO | tr ' ' '\n' | sed "s/\($suid_perigosos\)/${UNDERLINED}${vermelho}&${sem_cor}/g"
    else
        echo "${DG}FIND BINARY NOT FOUND =[ $normal"
    fi
}



# ────  SÓ AMOSTRANDO OS NEGOCIO KKK ──────

echo "${normal}[${green}+${normal}]${green} [CONTAINER CPU] ${normal}--------> "${cpu_info}
echo "${normal}[${green}+${normal}] ${green}[CONTAINER KERNEL] ${normal}-----> "${kernel_container}
echo "${normal}[${green}+${normal}] ${green}[CONTAINER ARCH] ${normal}-------> "${arch}
echo "${normal}[${green}+${normal}] ${green}[CONTAINER USER] ${normal}-------> "${usuario}
echo "${normal}[${green}+${normal}] ${green}[CONTAINER GROUPS] ${normal}-----> "${groups}

# ────  COMANDOS ÚTEIS ──────

echo "${yellow} -- USEFUL COMMANDS  -- ${normal}"
comandos="curl wget gcc nc netcat ncat jq nslookup host hostname dig python python2 python3 nmap socat ctr docker go"
for CMD in ${comandos}; do
	tools="$tools $(command -v "${CMD}")"
done
echo "$(echo $tools | tr ' ' '\n')"

}

ipcont="$(hostname -I 2>/dev/null || hostname -i)"
ipdef=$(echo "$ipcont" | cut -d'.' -f1-3)
portas_legais=("22 53 80 81 8080 3216 8081 21 25 3000 3306 33060 3389 139 445 1434 389 636 3268 3269 8000")

hosts(){

echo "${yellow} -- CONTAINERS DISCOVERY  --"
echo "        ${DG}maybe slow .. ${normal}"


for i in {1..24}
do

    ip_lista2=$(ping -c 1 ${ipdef}.${i} 2>/dev/null | grep -v "recvmsg" |grep -v "ping" |  grep "bytes from"  | cut -d " " -f 4 | cut -d ":" -f 1)
    [[ -z "$ip_lista2" ]] && continue
    echo $ip_lista2 >> ips.txt
    echo "[$green+$normal] $ip_lista2"

done
}

portasNC(){
   for letter in $(cat ips.txt)
    do
        nc -nvz $letter $portas_legais > portas.txt
    done 
}

portasBASH(){

for letter in $(cat ips.txt)
    do
        for i in {22,53,80,81,8080,3216,8081,21,25,3000,3306,33060,3389,139,445,1434,389,636,3268,3269,8000} ; do
        PORT=$i
        (echo  > /dev/tcp/$letter/$PORT) >& /dev/null &&
        echo "${letter}${RED}:$PORT${normal}" 
        done
    done
}

portscan(){
    bashEXISTE=$(command -v bash)

    if [ -x "$bashEXISTE" ]; then
            portasBASH

    else
            portasNC
    fi
}

pergunta_sabia(){

    echo " "
    echo -n "[$vermelho!$normal] do u want to start the port scan? (y/n) --> "

    read desejo

    case "$desejo" in
        y|yes|YES|sim|s|Y|t"")
            echo ""
            echo "${yellow} -- PORT SCAN  -- ${DG}//maybe slow .. $normal"
            portscan
            rm ips.txt
        ;;
        n|no|nao|N)
            echo "bye !"
        ;;
        *)
    ;;
    esac
    
}

cve-verificacao(){
    echo ""
    echo "${yellow} -- CVE's CHECKER  -- ${DG} // red = vulnerable $normal"
    dockerversao=$(docker --version | grep "version" | cut -d" " -f3 | tr ',' ' ')
    ver() { printf "%03.0f%03.0f%03.0f" $(echo "$1" | tr '.' ' ' | cut -d '-' -f1); } # créditos ao deepce por essa função :P

    if [ "$(ver "$dockerversao")" -lt "$(ver 18.9.5)" ]; then
        echo "[${RED}!${normal}] ${RED}CVE-2019-13139${normal} ${DG} https://www.cvedetails.com/cve/CVE-2019-13139/ $normal" 
    else
        echo "[${green}+${normal}] ${green}CVE-2019-13139${normal}"
    fi

    if [ "$(ver "$dockerversao")" -lt "$(ver 18.9.3)" ]; then
        echo "[${RED}!${normal}] ${RED}CVE-2019-13139${normal} ${DG} https://github.com/Frichetten/CVE-2019-5736-PoC $normal"
    else
        echo "[${green}+${normal}] ${green}CVE-2019-5736${normal}"
    fi

}

docker_verificar(){

    if [ -x "$(command -v docker)" ]; then
        cve-verificacao    
    else
        echo "${yellow} -- CVE's CHECKER  -- ${DG}"
        echo "${DG}[?] could not identify the docker version, binary not found. feels bad. $normal"

    fi
}

verificar_internet(){

    echo ""
    echo "${yellow} -- CHECKING INTERNET CONNECTION  -- $normal"
    if ! ping -c 1 gnu.org &>/dev/null ; then

        echo "${DG}container has no internet connection =[ $normal"

    else

        echo "[${green}+${normal}] ${green}container has internet connection !! =] ${normal}"

    fi

}

enumeration
verificar
suid
hosts
pergunta_sabia
docker_verificar
verificar_internet