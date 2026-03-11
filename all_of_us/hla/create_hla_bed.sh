gcloud storage cp 'gs://gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.dict' .

cat ./Homo_sapiens_assembly38.dict \
  | cut -f 2,3 \
  | egrep "HLA|chr6"  \
  | awk '{
    gsub("SN:", "", $1);
    gsub("LN:", "", $2);
    print $0
  }' \
  | awk '{print $1,1,$2}' \
  | tr " " "\t" \
  | awk '{if($1=="chr6"){print "chr6\t25000000\t35000000"}else{print $0}}'  > ./hla_chr6_alt.bed

