# How to release

1. ```VERSION=1.0.0+5```
1. ```OLDVERSION=$(grep ^version pubspec.yaml | awk '{{ print $2 }}')```
1. Update the version number: ```sed -i -e "s/^version: .*/version: $VERSION/" pubspec.yaml```
1. Commit it: ```git add pubspec.yaml && git commit -m "Tag version $VERSION"```
1. Tag with the following command: ```git tag -a "v$VERSION" -m "Version $VERSION"```
1. ```git push```
1. ```git push --tags```
1. ```flutter build appbundle```
1. Use this for the update log in the console: ```git log "v$OLDVERSION"..."v$VERSION" --pretty=format:"%h - %s"```
