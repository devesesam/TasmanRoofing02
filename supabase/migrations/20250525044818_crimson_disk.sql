/*
  # Add indexes for foreign keys

  1. New Indexes
    - Add index on worker_id column in jobs table
    - Add index on worker_id column in job_secondary_workers table

  2. Performance Impact
    - Improves query performance for joins and lookups on worker_id
    - Optimizes foreign key constraint checks
*/

-- Add index for jobs.worker_id foreign key
CREATE INDEX IF NOT EXISTS idx_jobs_worker_id 
ON public.jobs (worker_id);

-- Add index for job_secondary_workers.worker_id foreign key
CREATE INDEX IF NOT EXISTS idx_job_secondary_workers_worker_id 
ON public.job_secondary_workers (worker_id);