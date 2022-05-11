

process get_pharmvar_vcf {
    label 'S'
    publishDir "progress/get_pharmvar_vcf",  mode: params.intermediate_pub_mode
    tag {"${meta.pharmvar_gene}:${meta.pharmvar_ver}"}

    input:
        tuple val(am), val(meta)
        tuple path(ref), path(fai), path(dict)


    output:
        tuple val(am), path(vcf), path("${vcf}.tbi")

    script:
        gene = meta.pharmvar_gene
        ver = meta.pharmvar_ver
        url = "https://purple.psych.bio.uni-goettingen.de/plaster/${gene}-${ver}.zip"
        vcf = "${am}.pharmvar-$gene-${ver}.vcf.gz"
        """
        curl --insecure -I "$url" -o bundle.zip
        unzip bundle.zip
        for VCF in ./$gene-$ver/GRCh38/*.vcf
        do
            NAME=`basename \$VCF .vcf`
            NORM=\$NAME.norm.bcf
            ANN=\$NAME.ann.bcf
            bcftools norm \$VCF -f $ref -Ob -o \$NORM
            bcftools index \$NORM
            bcftools annotate \$NORM -a \$NORM -m \$NAME -Ob -o \$ANN
            bcftools index \$ANN
            rm \$NORM*
        done
        bcftools merge -m none *.ann.bcf -Oz -o $vcf
        bcftools index -t $vcf
        """
}
