version 1.0

workflow selectid_VCFs {

    meta {
	author: "Phuwanat Sakornsakolpat"
        email: "phuwanat.sak@mahidol.edu"
        description: "Select ID VCF"
    }

     input {
        File vcf_file
        File id_file
    }

    call run_selecting { 
			input: vcf = vcf_file, id=id_file
	}

    output {
        File selected_vcf = run_selecting.out_file
        File selected_tbi = run_selecting.out_file_tbi
    }

}

task run_selecting {
    input {
        File vcf
        File id
        Int memSizeGB = 8
        Int threadCount = 2
        Int diskSizeGB = 8*round(size(vcf, "GB")) + 20
	String out_name = basename(vcf, ".vcf.gz")
    }
    
    command <<<
	bcftools view -i 'ID=@~{id}' -Oz -o ~{out_name}.selected.vcf.gz ~{vcf}
	tabix -p vcf ~{out_name}.selected.vcf.gz
    >>>

    output {
        File out_file = select_first(glob("*.selected.vcf.gz"))
        File out_file_tbi = select_first(glob("*.selected.vcf.gz.tbi"))
    }

    runtime {
        memory: memSizeGB + " GB"
        cpu: threadCount
        disks: "local-disk " + diskSizeGB + " SSD"
        docker: "quay.io/biocontainers/bcftools@sha256:f3a74a67de12dc22094e299fbb3bcd172eb81cc6d3e25f4b13762e8f9a9e80aa"   # digest: quay.io/biocontainers/bcftools:1.16--hfe4b78e_1
        preemptible: 2
    }

}