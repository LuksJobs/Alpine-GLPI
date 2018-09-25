<?php
############################################
#Esse arquivo serve para realizar a conectar o banco de dados com a aplicação do GLPI;
#Necessário alterar ou adicionar o arquivo com a configuração do banco abaixo para quando for subir em ambientes de homologação/produção ou migração de servidores;
#Arquivo localizado no diretório dentro do container GLPI: /var/www/html/glpi/config;
############################################

class DB extends DBmysql {
   #adicionar host do banco;
   public $dbhost     = '10.16.41.1:32772'; 
   #adicionar usuário do banco;
   public $dbuser     = 'glpiadmin';
   #adicionar senha do usuário do banco;
   public $dbpassword = 'ult%4032XT';
   #adicionar schema do banco;
   public $dbdefault  = 'glpi';
}
