Tradition-Registry

Version: 1.0.0

Summary: A decentralized registry for communities to log, document, and preserve their cultural traditions on-chain.

📖 Description

The Tradition-Registry smart contract enables communities to register and maintain detailed records of their cultural practices, ensuring their preservation for future generations. Each registered tradition includes its name, description, associated community, creator address, creation block height, and preservation status.

The contract maintains both a global registry of traditions and a community-specific mapping, allowing users to easily retrieve cultural data per community.

⚙️ Features

Register new traditions:
Communities can add unique traditions with descriptive details and community identifiers.

Update existing traditions:
Only the original creator of a tradition can update its description.

Query registered traditions:
Retrieve individual traditions, all traditions under a specific community, or the total number of registered traditions.

Find by name:
Search for a specific tradition within a community by its name.

Data validation:
Input validation ensures that empty names, descriptions, or community identifiers are not accepted.

🗂️ Data Structures
Global Counter

tradition-counter → tracks the total number of registered traditions.

Maps

traditions → stores individual traditions by unique tradition-id.
Each entry includes:

{
  name: (string-ascii 100),
  description: (string-ascii 500),
  community: (string-ascii 50),
  creator: principal,
  created-at: uint,
  preserved: bool
}


community-traditions → maps each community name to a list (max 100) of tradition-ids.

🧩 Public Functions
(register-tradition name description community)

Registers a new tradition under a specific community.

Returns: (ok tradition-id) on success

Errors:

u103 → Invalid input

(update-tradition tradition-id description)

Updates the description of an existing tradition.

Access Control: Only the creator of the tradition can modify it.

Returns: (ok true) on success

Errors:

u100 → Not authorized

u102 → Tradition not found

u103 → Invalid input

📚 Read-Only Functions
Function	Description
(get-tradition tradition-id)	Fetch details of a specific tradition.
(get-community-traditions community)	Retrieve all tradition IDs under a given community.
(get-tradition-count)	Get total number of registered traditions.
(get-tradition-by-community-and-name community target-name)	Search for a tradition in a community by name.

🔒 Private Functions

Used internally for lookup logic:

(find-tradition-by-name) → Iterates through a list of IDs to find a match by name.

(check-tradition-name-match) → Helper used by the fold operation for comparison.

🚨 Error Codes
Code	Meaning
u100	Not authorized
u101	Tradition already exists
u102	Tradition not found
u103	Invalid input

🧠 Example Usage
;; Register a new tradition
(contract-call? .tradition-registry register-tradition "New Yam Festival" "A celebration marking the harvest of new yams" "Igbo")

;; Update a tradition
(contract-call? .tradition-registry update-tradition u1 "An annual harvest festival celebrating community unity")

;; Get a specific tradition
(contract-call? .tradition-registry get-tradition u1)

🧾 License
MIT License