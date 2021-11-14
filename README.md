# tendi-revenue-dist
> Current project is based on nodejs 16.12 and yarn 1.22.17
### Download from github
Download zip file or git clone https://github.com/zess11/tendi-revenue-dist.git<br>
### Install
Go to the source directory and open terminal, please run this command.<br>
> npm install
### Compile
> npx hardhat compile
### Config
Rename .env.example to .env and open it, then fill the mainnet url and account's private key.<br>
> PRIVATE_KEY=Your mainnet account's private key<br>
> PROVIDER_URL=Your mainnet infra url<br>

For example<br>
![image](https://user-images.githubusercontent.com/82226713/140091960-48f40dde-0207-4506-a7f3-fcda524f5eb9.png)
As you can see, you just copy and past your mainnet's infra url and account's private key for deploying.<br>
Open the scripts/deploy.js and fill the Oracle's owner address at line 8.<br>
Oracle's owner is the account to access to Revenue contract from tendi-revenue-oracle service.<br>
You can also set this same account when deploy tendi-revenue-oracle service.<br>
![image](https://user-images.githubusercontent.com/82226713/140093993-ce83ce5a-8c05-4fac-b9f1-c53bca8b8f43.png)
Please run this command.<br>
> npx hardhat run scripts/deploy.js --network mainnet<br>

Once deployed, you can see the Revenue contract's address on terminal.<br>
**Save the Revenue contract's address and use it when deploy tendi-revenue-oracle service.**<br>
