if [ "$1" != "--nodel" ]; then
	echo Deleting ./app 
	rm -rf app
	mkdir app
else
	echo Not deleting ./app
fi

echo Copying src to app
cp -r src _temp
find _temp -type d -name '.svn' | xargs rm -rf
find _temp -name '*.coffee' | xargs rm -rf
find _temp -name '*.*~' | xargs rm -rf
cp -r _temp/* app
rm -rf _temp

# echo Compiling coffee to js
coffee -o app/ -c src/
#plugins directory doesn't need the function() wrapper
#coffee --bare -o app/website/scriptVM/scriptVM_Scripts -c src/website/scriptVM/scriptVM_Scripts
