./compile.sh $1
cd app/website
node --debug app.js "$1" "$2"
