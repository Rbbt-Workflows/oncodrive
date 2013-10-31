require 'rbbt/workflow'
require File.join(File.dirname(__FILE__), 'lib/oncodriveFM')

module Oncodrive
  extend Workflow

  input :study, :string, "Study code"
  task :analysis => :tsv do |study|
    study = Study.setup(study.dup)
    tsv, input, config = OncodriveFM.process_cohort(study.cohort, true)
    Open.write(file("input"), input)
    Open.write(file("config"), config)
    tsv.namespace = study.metadata[:organism]
    tsv
  end
end

module StudyWorkflow
  task :oncodrive => :tsv do 
    analysis = Oncodrive.job(:analysis, study, :study => study)
    analysis.run
    FileUtils.ln_s(analysis.path, self.path)
    FileUtils.ln_s(analysis.files_dir, self.files_dir)
  end
end
