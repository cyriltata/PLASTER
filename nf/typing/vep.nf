

process vep {
    label 'M2'
    publishDir "output", mode: params.output_pub_mode
    tag { "$am" }

    input:
        tuple val(am), path(vcf), file(tbi)

    output:
        tuple val(am), path(out), file("${out}.tbi")

    script:
        out = "${am}.vep.vcf.gz"
        """
        ssh -4 -fN -L 6606:ensembldb.ensembl.org:3306 gwdu103
        vep --input_file $vcf \\
            --database \\
            --host localhost \\
            --port 6606 \\
            --format vcf \\
            --vcf \\
            --everything \\
            --allele_number \\
            --variant_class \\
            --dont_skip \\
            --assembly $params.vep_assembly \\
            --cache_version $params.vep_cache_ver \\
            --allow_non_variant \\
            --pick_allele_gene \\
            --output_file STDOUT |
            bcftools view --no-version -Oz -o $out
        bcftools index -t $out
        """
}
