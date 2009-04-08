<VirtualHost 94.23.0.160:80>
ServerName blank.thinkdry.com

   RailsEnv production
   DocumentRoot /home/rails/blank/current/public/
   <Directory "/home/rails/blank/current/public/">
      Options FollowSymLinks
      AllowOverride None
      Order allow,deny
      Allow from all
   </Directory>

   CustomLog /var/log/apache2/blank.thinkdry.com-access.log combined
   ErrorLog /var/log/apache2/blank.thinkdry.com-error.log
</VirtualHost>

