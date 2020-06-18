#!/bin/bash
echo "$mongo_cert" > /tmp/mongo_cert.crt
counts_uri=$(sed "s/\(.*\)admin/\1counts/" <<<"$mongo_url")
precomputed_uri=$(sed "s/\(.*\)admin/\1precomputed/" <<<"$mongo_url")
word_embeddings_uri=$(sed "s/\(.*\)admin/\1word_embeddings/" <<<"$mongo_url")
IFS=',' read -r -a embeds <<< "$embeddings"
for embedding in "${embeds[@]}"
do
    IFS=':' read -r -a parsed <<< "$embedding"
    col=${parsed[0]}
    timestamp=${parsed[1]}
    dimension=${parsed[2]}
    collection=$col"_"$timestamp
    counts_splits=${parsed[3]}
    counts_documents=${parsed[4]}
    precomputed_splits=${parsed[5]}
    precomputed_documents=${parsed[6]}
    word_embeddings_splits=${parsed[7]}
    word_embeddings_documents=${parsed[8]}
    
    # Check and make sure the data is copied over from data images
    echo "Verifying $collection data is available"
    echo "Expecting $counts_splits parts to counts collection"
    echo "Expecting $precomputed_splits parts to precomputed collection"
    echo "Expecting $word_embeddings_splits parts to word_embeddings collection"
    
    counts_file="/data/counts.$col.$timestamp.gz.complete"
    if [[ $counts_splits -gt 1 ]]; then
      counts_file="/data/counts.$col.$timestamp.gz.part-*.complete"
    fi
    echo "$counts_file"
    counts=$(ls -al $counts_file | wc -l)
    if [ $counts -ne $counts_splits ]; then
      echo "found $counts counts files, cannot continue load"
      exit 1
    fi
    echo "Found all $counts_splits count files"
    precomputed_file="/data/precomputed.$col.$timestamp.gz.complete"
    if [[ $precomputed_splits -gt 1 ]]; then
      precomputed_file="/data/precomputed.$col.$timestamp.gz.part-*.complete"
    fi
    echo "$precomputed_file"
    precomputed=$(ls -al $precomputed_file | wc -l)
    if [ $precomputed -ne $precomputed_splits ]; then
      echo "found $precomputed precomputed files, cannot continue load"
    fi
    echo "Found all $precomputed_splits precomputed files"
    word_embeddings_file="/data/word_embeddings.$col.$timestamp.gz.complete"
    if [[ $word_embeddings_splits -gt 1 ]]; then
      word_embeddings_file="/data/word_embeddings.$col.$timestamp.gz.part-*.complete"
    fi
    echo "$word_embeddings_file"
    word_embeddings=$(ls -al $word_embeddings_file | wc -l)
    if [ $word_embeddings -ne $word_embeddings_splits ]; then
      echo "found $word_embeddings word_embeddings files, cannot continue load"
    fi
    echo "Found all $word_embeddings_splits word_embeddings files"
    # -- should have all data for this language and can begin loading it
    
    if ( [ ! -f "/data/precomputed.$col.$timestamp.gz" ] || [ ! -f "/data/word_embeddings.$col.$timestamp.gz" ] ); then
        echo "Each language must have counts, precomputed and word_embeddings exports"
        echo "$col is missing corresponding archives"
        exit 1
    fi
    
    import_db() {
         old_collection="$1.$col"
         new_collection="$1.$col""_"$timestamp
         echo "Importing from $old_collection to $new_collection"
         mongorestore --archive=/data/$1.$col.$timestamp.gz --gzip --ssl --sslAllowInvalidCertificates --uri $mongo_url --drop --nsFrom=$old_collection --nsTo=$new_collection
    }
    
    echo "Beginning import of $col"
    start=$SECONDS
    counts=$(mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/mongo_cert.crt --authenticationDatabase=admin "$counts_uri" --eval "rs.slaveOk();printjson(db.getCollection('$collection').count())" --quiet | tail -1)
    while ! [[ "$counts" =~ ^[0-9]+$ ]] || [ "$counts" -ne "$counts_documents" ]; do
      echo "$col counts collection is not loaded, $counts vs $counts_documents, running import_db"
      import_db "counts"
      counts=$(mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/mongo_cert.crt --authenticationDatabase=admin "$counts_uri" --eval "rs.slaveOk();printjson(db.getCollection('$collection').count())" --quiet | tail -1)
    done
    
    precomputed=$(mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/mongo_cert.crt --authenticationDatabase=admin "$precomputed_uri" --eval "rs.slaveOk();printjson(db.getCollection('$collection').count())" --quiet | tail -1)
    while ! [[ "$precomputed" =~ ^[0-9]+$ ]] || [ "$precomputed" -ne "$precomputed_documents" ]; do
      echo "$col precomputed collection is not loaded, $precomputed vs $precomputed_documents, running import_db"
      import_db "precomputed"
      precomputed=$(mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/mongo_cert.crt --authenticationDatabase=admin "$precomputed_uri" --eval "rs.slaveOk();printjson(db.getCollection('$collection').count())" --quiet | tail -1)
    done
    
    word_embeddings=$(mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/mongo_cert.crt --authenticationDatabase=admin "$word_embeddings_uri" --eval "rs.slaveOk();printjson(db.getCollection('$collection').count())" --quiet | tail -1)
    while ! [[ "$word_embeddings" =~ ^[0-9]+$ ]] || [ "$word_embeddings" -ne "$word_embeddings_documents" ]; do
      echo "$col word_embeddings collection is not loaded, $word_embeddings vs $word_embeddings_documents, running import_db"
      import_db "word_embeddings"
      word_embeddings=$(mongo --ssl --sslAllowInvalidCertificates --sslCAFile=/tmp/mongo_cert.crt --authenticationDatabase=admin "$word_embeddings_uri" --eval "rs.slaveOk();printjson(db.getCollection('$collection').count())" --quiet | tail -1)
    done
    end=$(( SECONDS - start ))
    echo "Import completed in $end seconds"
done
rm -f /tmp/mongo_cert.crt
echo "All languages have been loaded"
exit 0
