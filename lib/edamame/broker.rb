module Edamame
  #
  # Repeatedly poll the queue for jobs and dispatch them to a worker loop
  #
  # Those jobs can be rescheduled (with updated parameters) for later
  # re-processing.
  #
  class Broker < PersistentQueue
    # Enter the work loop
    def work timeout=nil, klass=nil, &block
      loop do
        job    = reserve(timeout, klass) or break
        result = block.call(job)
        reschedule job
      end
    end

    # Inserts the job back into the queue at its sepcified delay --
    # or, if delay is nil, remove the job from the queue
    #
    # You'll probably want to use Edamame::Scheduling with all this
    def reschedule job
      delay = job.scheduling.delay
      if delay
        release job
      else
        log_job job, 'deleted'
        delete job
      end
    end

    # Log info about an action on a job
    def log_job job, *stuff
      Log.info [job.tube, job.priority, job.delay, job.obj['key'], *stuff].flatten.join("\t")
    end

  end
end
