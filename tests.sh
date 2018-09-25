#!/usr/bin/env bash

## Confiurações locais
build_tags_file="${PWD}/build.sh~tags"
docker_run_options='--detach'

## Configurações de inicialização
set -e
set -x

source ${PWD}/_tools.sh

## Processo de realização de testes
#1 Verificar se o build deu certo, caso, der certo retorna mensagem de conclusão.
echo '-> 1 Teste de build verificada com sucesso!'
[ -f "${build_tags_file}" ]

# Verificando imagem padrão
echo '-> Verificando imagem padrão'
image=`head --lines=1 "${build_tags_file}"`

#2 Verificando se o GLPI foi testado com sucessso
echo '-> 2 Verificando se o GLPI foi instalado com sucesso'
image_name=glpi_2
docker run --rm $docker_run_options --name "${image_name}" "${image}" test -f index.php

#3 Teste de verificação da instalação dos plugins
echo '-> 3  Teste de verificação da instalação dos plugins: tar.bz2'
image_name=glpi_3
docker run $docker_run_options --name "${image_name}" --env='GLPI_INSTALL_PLUGINS=fusioninventory|https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi9.2%2B1.0/glpi-fusioninventory-9.2.1.0.tar.bz2' "${image}"
wait_for_string_in_container_logs "${image_name}" 'Inicializando...'
if ! docker exec "${image_name}" test -d plugins/fusioninventory; then
  docker logs "${image_name}"
  false
fi
stop_and_remove_container "${image_name}"

#4 Teste de verificação da instalação dos plugins tar.gz
echo '-> 4 Teste de verificação da instalação dos plugins: tar.gz'
image_name=glpi_4
docker run $docker_run_options --name "${image_name}" --env='GLPI_INSTALL_PLUGINS=fusioninventory|https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi9.1%2B1.1/fusioninventory-for-glpi_9.1.1.1.tar.gz' "${image}"
wait_for_string_in_container_logs "${image_name}" 'Inicializando...'
#test
if ! docker exec "${image_name}" test -d plugins/fusioninventory; then
  docker logs "${image_name}"
  false
fi
stop_and_remove_container "${image_name}"

#5 Teste de verificação da instalação dos plugins com váriaveis antigas
echo '-> 5 Teste de verificação da instalação dos plugins com váriaveis antigas'
image_name=glpi_5
docker run $docker_run_options --name "${image_name}" --env='GLPI_PLUGINS=fusioninventory|https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi9.1%2B1.1/fusioninventory-for-glpi_9.1.1.1.tar.gz' "${image}"
wait_for_string_in_container_logs "${image_name}" 'Inicializando...'
#test
if ! docker exec "${image_name}" test -d plugins/fusioninventory; then
  docker logs "${image_name}"
  false
fi
stop_and_remove_container "${image_name}"

#6 Testando o Acesso via Web 
echo '-> 6 Testando o Acesso via Web '
image_name=glpi_6
docker run $docker_run_options --name "${image_name}" --publish 10002:80 "${image}"
wait_for_string_in_container_logs "${image_name}" 'nginx entered RUNNING state'
sleep 4
#test
if ! curl -v http://localhost:10002 2>&1 | grep --quiet 'install/install.php'; then
  docker logs "${image_name}"
  false
fi
stop_and_remove_container "${image_name}"
