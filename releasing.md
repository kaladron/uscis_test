# How to release

1. ```VERSION=1.0.0+6```
1. Update the version number: ```sed -i -e "s/^version: .*/version: $VERSION/" pubspec.yaml```
1. Commit it: ```git add pubspec.yaml && git commit -m "Tag version $VERSION"```
1. ```git push```
1. ```git push origin main:release/$VERSION```
