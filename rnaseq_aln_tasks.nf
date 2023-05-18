process trimReads {
        publishDir params.outdir, mode:'copy'

        input:
        tuple val(sample_id), path(reads)

        output:
        tuple val(sample_id), path('fastp/*.fastp.fastq.gz') , optional:true, emit: reads

        script:
        """
        mkdir fastp
        fastp -i ${reads[0]} -I ${reads[1]} -o fastp/${sample_id}.1.fastp.fastq.gz -O fastp/${sample_id}.2.fastp.fastq.gz --length_required 33 --cut_front --cut_tail --cut_mean_quality 20 --thread 1
        """
}

process fastqc {
        tag "FASTQC on $sample_id"
        
        input:
        tuple val(sample_id), path(reads)

        output:
        path("fastqc/${sample_id}")

        script:
        """
        mkdir -p fastqc/${sample_id}
        fastqc -o fastqc/${sample_id} --nogroup -f fastq -q ${reads} 
        """
}

process multiqc {
        publishDir params.outdir, mode:'move'

        input:
        val(prefix)
        path('*')

        output:
        path("${prefix}_multiqc")

        script:
        """
        multiqc -o ${prefix}_multiqc . 
        """
}

process indexGenomeHisat2 {

        input:
        path genome_f

        output:
        path "hisat2", emit: index

        script:
        """
        mkdir hisat2
        zcat ${genome_f} > hisat2/genome.fasta
        hisat2-build hisat2/genome.fasta hisat2/genome
        """
}

process mapToGenomeHisat2 {
        publishDir params.outdir, mode:'move'

        input:
        path(index)
        tuple val(sample_id), path(reads)

        output:
        path("bams/${sample_id}.sorted.bam")

        script:
        """
        mkdir -p hisat2/bams
        INDEX=`find -L ./ -name "*.1.ht2" | sed 's/\\.1.ht2\$//'`
        hisat2 -x \$INDEX -1 ${reads[0]} -2 ${reads[1]} | samtools view -bS | samtools sort -o hisat2/bams/${sample_id}.sorted.bam
        """
}
