# Test the Spec Client Locally

The following workflow will show you how to run the Spec client locally against your local Postgres database + how to add your first live table and see Spec in action.

### 1) Installation

First, install both the Spec CLI and the Spec client as global npm modules.

```bash
$ npm install -g @spec.dev/cli @spec.dev/spec
```
### 2) Create a new local database

Create a fresh database for your new Spec "project":

```bash
$ createdb testing
```

### 3) Create a new folder for your Spec project

```bash
$ mkdir client-test && cd client-test
```

**The rest of the steps will assume you are *inside* your new `client-test` folder**

### 4) Log into the Spec CLI

```bash
$ spec login
```

### 5) Initialize a new Spec project

```bash
$ spec init
```

This will create 2 files inside a new `.spec` folder:
1) `connect.toml` - Specifies the different database environments to run the Spec client against
2) `project.toml` - Specifies which live tables you want in your database and their respective data mappings

### 5) Link the remote Spec project to this local folder

I went ahead and created a new Spec project named `test` that exists under the `test` namespace in our Core DB. This project (like all of them) has its own set of API credentials. When you run the following command, the Spec CLI will automatically pull down those API credentials for you. It then tells the CLI that this folder (`client-test`, or `.`) is the local location of the `test/test` project.

```bash
$ spec link project test/test .
```

### 6) Specify the database you want the Spec client to run against

Open `.spec/connect` and configure the rest of the local database connection info:

```toml
# Local database
[local]
name = 'testing'
port = 5432
host = 'localhost'
user = 'your-username' # whatever shows up to the left when you just type 'psql' and hit enter
password = '' # leave blank
```

### 7) Create the table that will hold live ethereum blocks data

For this example, we're going to assume you want a live table in your database that holds all ethereum blocks published after block number `18100000`. If you were using the Spec desktop app, Spec would automatically create the underlying table *for you*, but without the desktop app, we will create the underlying table manually:

```bash
psql testing -f ../helpers/create-blocks-table.sql
```

### 8) Add the Ethereum Blocks live object to your project

The Spec desktop app will also automatically write your project.toml file for you, but let's just write it from scratch. Replace your `.spec/project.toml` file with the following contents:

```toml
# = Live Objects (Sources) ------------------------------

[objects.Block]
id = 'eth.Block@0.0.1'

# = Live Columns (Outputs) ------------------------------

[tables.public.blocks]
number = 'Block.number'
hash = 'Block.hash'
timestamp = 'Block.timestamp'
parent_hash = 'Block.parentHash'
nonce = 'Block.nonce'
sha3_uncles = 'Block.sha3Uncles'
logs_bloom = 'Block.logsBloom'
transactions_root = 'Block.transactionsRoot'
state_root = 'Block.stateRoot'
receipts_root = 'Block.receiptsRoot'
miner = 'Block.miner'
difficulty = 'Block.difficulty'
total_difficulty = 'Block.totalDifficulty'
size = 'Block.size'
extra_data = 'Block.extraData'
gas_limit = 'Block.gasLimit'
gas_used = 'Block.gasUsed'
base_fee_per_gas = 'Block.baseFeePerGas'
transaction_count = 'Block.transactionCount'

# = Links & Filters --------------------------------------

[[objects.Block.links]]
table = 'public.blocks'
uniqueBy = [ 'number' ]
filterBy = [
	{ number = { op = '>', value = '18100000' } },
]
```

This file tells the Spec client 4 things:<br>
1) That your database needs data from the `eth.Block@0.0.1` Live Object
2) The exact 1:1 mapping between an `eth.Block` record and your `blocks` table
3) `uniqueBy` - The group of columns to use within the `ON CONFLICT(...)` clause when upserting an `eth.Block` record into the `blocks` table.
4) `filterBy` - Which subset of `eth.Block` Live Object records you want (all blocks where `number > 18100000`). This is used up-front when performing the initial backfill of the live table (HTTP request to the Tables API `/stream`), and then on an on-going basis to filter new events coming from the event-relay.

### Run the Spec client

Now that you have a local table ready to house the live data and the config file specifying your exact data mappings, the Spec client should be ready to run.

```bash
$ spec start
```

![](https://vhs.charm.sh/vhs-4BaqGeP0TSjJTkTbrnpU7C.gif)
