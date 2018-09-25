#!/bin/sh

set -e

basedir="${GLPI_PATHS_ROOT}"

## Instalação de Plugins ##
###########################
# Instalando um plugin;
# param1: o nome do plugin (diretório)
# param2: o url de download do plugin (url completa)
###########################

function installPlugin() {
  plugin="${1}"
  url="${2}"
  file="$(basename "$url")"

  # continua caso o plugin já esteja instlado
  if [ -d "$plugin" ]; then
    echo "..plugin ${plugin} já instalado"
    continue
  fi
  # Download do plugin se a source não existir
  if [ ! -f "${file}" ]; then
    echo "..downloading do plugin '${plugin}' atraveps '${url}'"
    curl -o "${file}" -L "${url}"
  fi
  
  # extrair o arquivo de acordo com a extensão
  echo "..extraindo plugin '${file}'"
  case "$file" in
    *.tar.gz)
      tar xzf "${file}"
      ;;
    *.tar.bz2)
      tar xjf "${file}"
      ;;
    *)
      echo "..#ERROR# extensão do arquivo desconhecida: ${file}." 1>&2
      false
      ;;
  esac
  if [ $? -ne 0 ]; then
    echo "..#ERROR# falha ao extrair o arquivo: ${plugin}" 1>&2
    continue
  fi

  # removendo pasta e setando permissões ao arquivo.
  rm -f "${file}"
  chown -R www-data:www-data "${plugin}"
  chmod -R g=rX,o=--- "${plugin}"
}

echo "Instalando plugin em: ${GLPI_PATHS_PLUGINS}"
cd "${GLPI_PATHS_PLUGINS}" > /dev/null

# Use a nova syntaxe
if [ ! -z "${GLPI_INSTALL_PLUGINS}" ]; then
  OLDIFS=$IFS
  IFS=','
  for item in ${GLPI_INSTALL_PLUGINS}; do
    IFS=$OLDIFS
    name="${item%|*}"
    url="${item#*|}"
    installPlugin "${name}" "${url}"
  done
fi

# Configuração de plugins antigos
if [ ! -z "${GLPI_PLUGINS}" ]; then
  echo "..#WARNING# A pasta GLPI_PLUGINS está obsoleto, use o novo GLPI_INSTALL_PLUGINS" 1>&2
  for item in ${GLPI_PLUGINS}; do
    name="${item%|*}"
    url="${item#*|}"
    installPlugin "${name}" "${url}"
  done
fi
cd - > /dev/null

## Remover arquivo de instalação do GLPI;
echo 'Removendo arquivos de instalação ...'
# usado para remover o arquivo de instalaçãp do GLPI;
if [ "x${GLPI_REMOVE_INSTALLER}" = 'xyes' ]; then
  rm -f "${basedir}/install/install.php"
fi

## Estrutura de arquivos
echo "Criando estruturas de arquivos 'files' ..."
for f in _cache _cron _dumps _graphs _lock _log _pictures _plugins _rss _sessions _tmp _uploads; do
  dir="${basedir}/files/${f}"
  if [ ! -d "${dir}" ]; then
    mkdir -p "${dir}"
    chown www-data:www-data "${dir}"
    chmod u=rwX,g=rwX,o=--- "${dir}"
  fi
done

## Permissão dos arquivos 
echo 'Setando permissões nos arquivos...'
if [ "x${GLPI_CHMOD_PATHS_FILES}" = 'xyes' ]; then
  chown -R www-data:www-data "${basedir}/files"
  chmod -R u=rwX,g=rX,o=--- "${basedir}/files"
fi

## Inicialiando supervisord
echo 'Inicializando gerenciador de processo Supervisord...'
exec /usr/bin/supervisord --configuration /etc/supervisord.conf
