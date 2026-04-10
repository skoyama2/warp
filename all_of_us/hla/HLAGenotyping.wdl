version 1.0

## HLA region extraction: GATK PrintReads over gs:// inputs (e.g. Broad public references).
## Requester-pays buckets require a billing project; pass it as `google_project`.

workflow HLAGenotyping {
  input {
    File ref_fasta
    File input_cram
    File hla_bed
    String google_project

    String gatk_docker = "us.gcr.io/broad-gatk/gatk:4.6.2.0"
    String gatk_jar = "/gatk/gatk-package-4.6.2.0-local.jar"
    String output_filename = "hla-unsorted.bam"
  }

  call PrintReadsHLA {
    input:
      ref_fasta = ref_fasta,
      input_cram = input_cram,
      hla_bed = hla_bed,
      google_project = google_project,
      gatk_docker = gatk_docker,
      gatk_jar = gatk_jar,
      output_filename = output_filename
  }

  output {
    File hla_unsorted_bam = PrintReadsHLA.hla_unsorted_bam
  }
}

task PrintReadsHLA {
  input {
    File ref_fasta
    File input_cram
    File hla_bed
    String google_project

    String output_filename
    String gatk_docker
    String gatk_jar

    Int? disk_space_gb
    Int? preemptible_attempts
  }

  command <<<
    set -euo pipefail

    java \
      -Dsamjdk.use_async_io_read_samtools=false \
      -Dsamjdk.use_async_io_write_samtools=true \
      -Dsamjdk.use_async_io_write_tribble=false \
      -Dsamjdk.compression_level=2 \
      -jar ~{gatk_jar} PrintReads \
      -R ~{ref_fasta} \
      -I ~{input_cram} \
      -L ~{hla_bed} \
      -O ~{output_filename} \
      --gcs-project-for-requester-pays ~{google_project}
  >>>

  output {
    File hla_unsorted_bam = "~{output_filename}"
  }

  runtime {
    docker: gatk_docker
    memory: "4 GB"
    disks: "local-disk " + select_first([disk_space_gb, 100]) + " HDD"
    preemptible: select_first([preemptible_attempts, 2])
  }

  parameter_meta {
    ref_fasta: { localization_optional: true }
    input_cram: { localization_optional: true }
    hla_bed: { localization_optional: true }
  }
}
