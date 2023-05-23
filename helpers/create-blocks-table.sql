BEGIN;
    CREATE TABLE public.blocks (id serial, number int8 NOT NULL, hash varchar, timestamp timestamptz, parent_hash varchar, nonce varchar, sha3_uncles varchar, logs_bloom varchar, transactions_root varchar, state_root varchar, receipts_root varchar, miner varchar, difficulty varchar, total_difficulty varchar, size int8, extra_data varchar, gas_limit varchar, gas_used varchar, base_fee_per_gas varchar, transaction_count int8);
    ALTER TABLE public.blocks ADD CONSTRAINT pk_3kjcebssnvsmy9ffx22bla PRIMARY KEY (id);
    CREATE UNIQUE INDEX idx_qbug5ehjvnsk9tq96plis4 ON public.blocks (number);
COMMIT;