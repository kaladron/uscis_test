# How to release

1. ```VERSION=1.0.0+6```
1. Update the version number: ```sed -i -e "s/^version: .*/version: $VERSION/" pubspec.yaml```
1. Commit it: ```git add pubspec.yaml && git commit -m "Tag version $VERSION"```
1. Tag with the following command: ```git tag -a "v$VERSION" -m "Version $VERSION"```
1. ```git push```
1. ```git push --tags```
1. ```flutter build appbundle```
1. ```jarsigner -verbose -keystore /home/afterihavedreamed/key.jks -storepass *** build/app/outputs/bundle/release/app-release.aab key```
