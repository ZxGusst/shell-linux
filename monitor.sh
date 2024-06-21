#!/bin/bash

LOG_FILE="/home/gusst/script/monitor.log"

# Função para obter o uso da CPU e Memória
monitor_cpu_mem() {
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    CPU_USAGE=$(top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    MEM_TOTAL=$(free -m | awk 'NR==2{print $2}')
    MEM_USED=$(free -m | awk 'NR==2{print $3}')
    MEM_USAGE=$(echo "scale=2; $MEM_USED*100/$MEM_TOTAL" | bc)

    echo "$DATE - Uso de CPU: $CPU_USAGE% - Uso de Memória: $MEM_USAGE%" | tee -a $LOG_FILE

    if (( $(echo "$CPU_USAGE > 80.0" | bc -l) )); then
        echo "$DATE - ALERTA: Uso de CPU acima de 80%: $CPU_USAGE%" | tee -a $LOG_FILE
        echo "ALERTA: Uso de CPU acima de 80%: $CPU_USAGE%" >&2
    fi

    if (( $(echo "$MEM_USAGE > 80.0" | bc -l) )); then
        echo "$DATE - ALERTA: Uso de Memória acima de 80%: $MEM_USAGE%" | tee -a $LOG_FILE
        echo "ALERTA: Uso de Memória acima de 80%: $MEM_USAGE%" >&2
    fi
}

# Função para obter o uso do espaço em disco
monitor_disk_space() {
    DATE=$(date "+%Y-%m-%d %H:%M:%S")
    DISK_USAGE=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//')

    echo "$DATE - Uso de Disco em /: $DISK_USAGE%" | tee -a $LOG_FILE

    if [ $DISK_USAGE -gt 90 ]; then
        echo "$DATE - ALERTA: Uso de Disco em / acima de 90%: $DISK_USAGE%" | tee -a $LOG_FILE
        echo "ALERTA: Uso de Disco em / acima de 90%: $DISK_USAGE%" >&2
    fi

    HOME_USAGE=$(df -h /home | awk 'NR==2{print $5}' | sed 's/%//')
    echo "$DATE - Uso de Disco em /home: $HOME_USAGE%" | tee -a $LOG_FILE

    if [ $HOME_USAGE -gt 90 ]; then
        echo "$DATE - ALERTA: Uso de Disco em /home acima de 90%: $HOME_USAGE%" | tee -a $LOG_FILE
        echo "ALERTA: Uso de Disco em /home acima de 90%: $HOME_USAGE%" >&2
    fi
}

# Função principal para chamar outras funções
monitor_system() {
    monitor_cpu_mem
    monitor_disk_space
}

# Executa a função de monitoramento
monitor_system