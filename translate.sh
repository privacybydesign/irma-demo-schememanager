#!/bin/bash

# This script ATTEMPTS TO convert all description.xml files of the scheme manager
# located at the specified subfolder to the new XML schema that supports
# translations. It SHOULD do the following:
# - to all tags that should be translatable, <en></en><nl></nl> subtags are given
# - the <en> tags are populated with the original content of these tags
# - the <Name> tags of an <Attribute> also receive their content in an "id" attribute
#   (these are internal identifiers and will remain being used)
# - the "version" attribute of the root tag is updated to the appropriate number.
#
# Dutch translations are not provided.
#
# You must still manually check each file!
# These are simple regexps and may break immediately if their input is not exactly
# right (e.g. spacing, subtabs). This is just a convenience tool, only tested on OS X,
# and the output is certainly not guaranteed to be correct.


SCHEMEMANAGER=$1

for file in $(find . -path "./${SCHEMEMANAGER}/*/Issues/*/description.xml"); do
	# Update schema version
	perl -pi -e 's~version="\d+"~version="4"~' $file

	# Remove newlines in tags
	perl -pi -0 -w -e  's|<Description>\s+(.*)\s*</.*?>|<Description>$1</Description>|ag' $file

	# Remove <id> tags
	perl -pi -e 's|^\s*<Id>\d+</Id>||' $file

	# Translate attribute names
	perl -pi -0 -w -e 's|(?<!">)\n(\s+)<Name>(.*?)</Name>|\n$1<Name id="$2">\n\t$1<en>$2</en>\n\t$1<nl></nl>\n$1</Name>|g' $file

	# Translate credential names
	perl -pi -0 -w -e 's|(?<!Attribute>)\n(\s+)<Name>(.*?)</Name>|\n$1<Name>\n\t$1<en>$2</en>\n\t$1<nl></nl>\n$1</Name>|g' $file

	# Translate other tags
	perl -pi -e 's~^(\s*)<(ShortName|Description)>(.*?)</.*?>~$1<$2>\n\t$1<en>$3</en>\n\t$1<nl></nl>\n$1</$2>~' $file
done

for file in $(find . -path "./${SCHEMEMANAGER}/*/description.xml" -a -not -path "./*/Issues/*"); do
	# Update schema version
	perl -pi -e 's~version="\d+"~version="4"~' $file

	# Translate tags
	perl -pi -e 's~^(\s*)<(ShortName|Name)>(.*?)</.*?>~$1<$2>\n\t$1<en>$3</en>\n\t$1<nl></nl>\n$1</$2>~' $file
done

# Update schema version
perl -pi -e 's~version="\d+"~version="7"~' "./${SCHEMEMANAGER}/description.xml"

# Translate tags
perl -pi -e 's~^(\s*)<(Name|Description)>(.*?)</.*?>~$1<$2>\n\t$1<en>$3</en>\n\t$1<nl></nl>\n$1</$2>~' "./${SCHEMEMANAGER}/description.xml"