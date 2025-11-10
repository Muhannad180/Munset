-- Enable the vector extension if not already enabled
create extension if not exists vector;

-- Create the documents table
create table if not exists documents (
    id uuid default gen_random_uuid() primary key,
    content text not null,
    embedding vector(1536),  -- OpenAI embeddings are 1536 dimensions
    metadata jsonb default '{}'::jsonb,
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now()
);

-- Create a function to update the updated_at timestamp
create or replace function update_updated_at_column()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

-- Create a trigger to automatically update the updated_at column
create trigger update_documents_updated_at
    before update on documents
    for each row
    execute function update_updated_at_column();

-- Create an index for faster similarity search
create index if not exists documents_embedding_idx on documents
using ivfflat (embedding vector_cosine_ops)
with (lists = 100);