# last update on: Jul/22/2019
# author: gunfus@gmail.com
#
# How to use it:
# --------------
#  Replace: 
#   "==REPLACE_WITH_BASIC_AUTH_FOR_SPIUSER==" with the proper encoded password for your SPIUSER
#   "my_wcs.com" with the proper domain of your company website
#
#  Run:
#   run the utility with no parameters

# ###
# Retrieve the index version
# ###
AUTH_indexCoreName_generic=`curl -s -k -H 'Authorization: Basic ==REPLACE_WITH_BASIC_AUTH_FOR_SPIUSER==' 'https://search-auth.my_wcs.com/solr/MC_10002_indexCoreName_generic/replication?command=indexversion' |grep -i indexversion`
REPEATER_indexCoreName_generic=`curl -s -k -H 'Authorization: Basic ==REPLACE_WITH_BASIC_AUTH_FOR_SPIUSER==' 'https://searchrepeater.my_wcs.com/solr/MC_10002_indexCoreName_generic/replication?command=indexversion' |grep -i indexversion`
LIVE_indexCoreName_generic=`curl -s -k -H 'Authorization: Basic ==REPLACE_WITH_BASIC_AUTH_FOR_SPIUSER==' 'https://search.my_wcs.com/solr/MC_10002_indexCoreName_generic/replication?command=indexversion' |grep -i indexversion`

 

# ###
# Trim the text around leaving only the index version numerical
# ###
AUTH_indexCoreName_generic=`echo $AUTH_indexCoreName_generic| cut -d':' -f2| cut -d',' -f1`
REPEATER_indexCoreName_generic=`echo $REPEATER_indexCoreName_generic| cut -d':' -f2| cut -d',' -f1`
LIVE_indexCoreName_generic=`echo $LIVE_indexCoreName_generic| cut -d':' -f2| cut -d',' -f1`

 

set -x

 

# ###
# Print out the index versions retrieved
# ###

 

echo
echo "========== AUTH INDEX VERSION RETRIEVED =========="
echo
echo "AUTH_indexCoreName_generic=$AUTH_indexCoreName_generic"
echo
echo "========== REPEATER INDEX VERSION RETRIEVED =========="
echo
echo "REPEATER_indexCoreName_generic=$REPEATER_indexCoreName_generic"
echomy_wcs.co
echo "========== LIVE INDEX VERSION RETRIEVED =========="
echo
echo "LIVE_indexCoreName_generic=$LIVE_indexCoreName_generic"
echo

 


# ###
# Force the index prop
# ###

 


INDEX_PROP_JSON=$(curl -s -k -H 'Authorization: Basic ==REPLACE_WITH_BASIC_AUTH_FOR_SPIUSER==' 'https://searchrepeater.my_wcs.com/solr/MC_10002_indexCoreName_generic/replication?command=fetchindex&indexversion=$AUTH_indexCoreName_generic')

 

echo
echo "---RAW JSON OUTPUT---BEGIN"
echo "$INDEX_PROP_JSON"
echo "---RAW JSON OUTPUT---END"
RETURN_CODE=$(echo $INDEX_PROP_JSON | jq '.responseHeader.status')
echo

 

 

# ###
# Print out the index versions retrieved - after the force
# ###

 

echo
echo "========== AUTH INDEX VERSION RETRIEVED =========="
echo
echo "AUTH_indexCoreName_generic=$AUTH_indexCoreName_generic"
echo
echo "========== REPEATER INDEX VERSION RETRIEVED =========="
echo
echo "REPEATER_indexCoreName_generic=$REPEATER_indexCoreName_generic"
echo
echo "========== LIVE INDEX VERSION RETRIEVED =========="
echo
echo "LIVE_indexCoreName_generic=$LIVE_indexCoreName_generic"
echo

 


exit $RETURN_CODE;