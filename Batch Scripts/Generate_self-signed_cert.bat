:: Generate a self-signed cert (for development):
dotnet dev-certs https -v -ep ./cert.pfx -p your-password

:: To explicity trust the dev cert
dotnet dev-certs https --trust

:: To get help 
dotnet dev-certs https --help
