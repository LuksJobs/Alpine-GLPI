# Alpine-GLPI
Alpine Linux é uma Distribuição Linux baseada em musl e BusyBox, originalmente projetado para usuários avançados que apreciam segurança, simplicidade e eficiência no uso de recursos. O GLPI é uma ferramenta de software ITSM gratuita e de código aberto que ajuda você a planejar e gerenciar mudanças de TI de maneira fácil, facilita na resolução de problemas eficientemente.

• Alpine: https://pkgs.alpinelinux.org/packages
<br>• GLPI: https://glpi-project.org/</br>

# Variáveis de Ambiente
Esta imagem considera essas variáveis como parâmetros:
<table>
<thead>
<tr>
<th>Environment</th>
<th>Type</th>
<th>Usage</th>
</tr>
</thead>
<tbody>
<tr>
<td>GLPI_REMOVE_INSTALLER</td>
<td>Boolean (yes/no)</td>
<td>Defina como sim se não for a primeira instalação do glpi</td>
</tr>
<tr>
<td>GLPI_CHMOD_PATHS_FILES</td>
<td>Boolean (yes/no)</td>
<td>Defina como sim para aplicar chmod/chown em /var/www/files (útil para montagem de host)</td>
</tr>
<tr>
<td>(deprecated) GLPI_PLUGINS</td>
<td>String</td>
<td>(será removido no 3.0) Lista separada por espaço de plugins para instalar (veja abaixo)</td>
</tr>
<tr>
<td>GLPI_INSTALL_PLUGINS</td>
<td>String</td>
<td>Lista separada por vírgula de plugins para instalar (veja abaixo) <</td>
</tr>
<tr>
<td>GLPI_ENABLE_CRONJOB</td>
<td>Boolean (yes/no)</td>
<td>Ative a execução interna do cron.php</td>
</tr></tbody></table>

• A variável <b>GLPI_INSTALL_PLUGINS</b> deve conter a lista de plugins a serem instalados (download) antes de iniciar o glpi. Esta variável de ambiente é uma lista separada por vírgula de definições de plug-ins. Cada definição de plugin deve ser assim "PLUGINNAME | URL". O PLUGINNAME é o nome da primeira pasta no arquivo do plugin e será o nome do glpi do plugin. O URL é o URL completo para baixar o plug-in. Esta url pode conter algumas extensões de arquivo compactadas, em alguns casos o script do instalador não poderá extraí-la, assim você pode criar um problema especificando a extensão de arquivo não manipulada. Esses dois itens são separados por um símbolo de pipe.
<br>• Para summurize, a variável <b>GLPI_INSTALL_PLUGINS</b> deve seguir o seguinte esqueleto GLPI_INSTALL_PLUGINS = "name1 | url1, name2 | url2" Para melhor exemplo, veja no final deste arquivo.</br>
<br>• Os volumes a seguir são expostos por esta imagem:</br>
<table>
<thead>
<tr>
<th>Volumes</th>
<th>Uso</th>
</tr>
</thead>
<tbody>
<tr>
<td>/var/www/files</td>
<td>O caminho de dados do GLPI</td>
</tr>
<tr>
<td>/var/www/config</td>
<td>O caminho de configuração do GLPI</td>
</tr></tbody></table>

# Conteúdo 
No Dockerfile contêm instâncias dos aplicativos da GLPI, Nginx e Php5-fpm exposto na porta 80.

# Note
Utilizaremos o no Travis no arquivo ".travis.yml" para iniciar o Docker quando criar um ambiente GLPI.

## Clonando ou baixando o repositório:

```$ docker build -t alpine/glpi .```

# Deploy do Container
Na primeira vez que você executar essa imagem, defina a variável GLPI_REMOVE_INSTALLER como 'no' e, depois dessa primeira instalação, defina como 'yes' para remover o instalador. 

### Sem link de banco de dados (você pode usar um endereço IP ou um nome de domínio na interface gŕafica do instalador)

```$ docker run --name glpi --publish 8000:80 --volume data-glpi:/var/www/files --volume data-glpi-config:/var/www/config alpine/glpi```

### Com link de banco de dados (se você tiver algum MySQL / MariaDB como um contêiner docker)

```$ docker run --name glpi --publish 8000:80 --volume data-glpi:/var/www/files --volume data-glpi-config:/var/www/config --link seubancodedados:mysql alpine/glpi```

### Exemplos de configuração específico do Docker-compose
Configuração de produção com o GLPI já instalado com o FusionInventory e o plug-in do painel:

```
services:
  glpi:
    image: luksjobs/glpi
    environment:
      - GLPI_REMOVE_INSTALLER=yes
      - 'GLPI_INSTALL_PLUGINS=fusioninventory|https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi9.2%2B1.0/glpi-fusioninventory-9.2.1.0.tar.bz2'
    ports:
      - 80
    volumes:
      - data-glpi-files:/var/www/files
      - data-glpi-config:/var/www/config
volumes:
  data-glpi-files:
  data-glpi-config:
  ```
