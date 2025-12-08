use dep::aztec::macros::aztec;

pub mod test;

#[aztec]
pub contract LogisticsOrderManagement {
    // aztec library imports
    use aztec::{
        macros::{
            functions::{external, initializer, internal, view}, 
            storage::storage,
            notes::{
                note,
                custom_note
            },
        },
        protocol_types::{
            address::AztecAddress,
            traits::Packable
        },
        state_vars::{
            PublicImmutable, PublicMutable, 
            PrivateImmutable, PrivateMutable, PrivateSet, 
            Map
        },
        oracle::random::random,
        messages::message_delivery::MessageDelivery
    };



    // @dev - The test Struct & its Note
    // @dev - A given "owner" will be a caller ("msg_sender"). Hence, a given "order_id" will be associated with a caller ("msg.sender").
    #[derive(Eq, Packable)]
    #[note]
    //#[custom_note]
    pub struct PrivateOrderNote {
        owner: AztecAddress,
        order_id: u128,
        order_quantity: u128,
        order_block_number: u32,  
        randomness: Field,
    }

    impl PrivateOrderNote {
        pub fn new(owner: AztecAddress, order_id: u128, order_quantity: u128, order_block_number: u32) -> Self {
            let randomness = unsafe { random() };

            // @dev - Return value ("Self" is equivalent to "PrivateOrderNote" struct)
            PrivateOrderNote { 
                owner,
                order_id: order_id,
                order_quantity, 
                order_block_number,
                randomness 
            }
        }

        pub fn get_private_order_note(self) -> (AztecAddress, u128, u128, u32, Field) {
            (self.owner, self.order_id, self.order_quantity, self.order_block_number, self.randomness)
        }

        pub fn get_owner(self) -> AztecAddress {
            self.owner
        }

        pub fn get_order_id(self) -> u128 {
            self.order_id
        }

        pub fn get_order_quantity(self) -> u128 {
            self.order_quantity
        }

        pub fn get_order_block_number(self) -> u32 {
            self.order_block_number
        }

        pub fn get_randomness(self) -> Field {
            self.randomness
        }
    }



    // @param owner The address of the owner
    // @param counter A numerical value
    #[storage]
    struct Storage<Context> {
        owner: PublicImmutable<AztecAddress, Context>,
        order_id: PublicMutable<u128, Context>,
        order_quantity: Map<u128, PrivateMutable<PrivateOrderNote, Context>, Context>,    /// @dev - order_id -> order_quantity
        //order_quantity: Map<AztecAddress, PrivateMutable<PrivateOrderNote, Context>, Context>,    /// @dev - order_id -> order_quantity
        order_block_number: Map<u128, PrivateMutable<u32, Context>, Context>,                   /// @dev - order_id -> order_block_number (UNIX timestamp)
    }

    /// @dev Initialize the contract
    /// @param owner The address of the owner
    #[external("public")]
    #[initializer]
    fn constructor(owner: AztecAddress) {
        storage.owner.initialize(owner);
    }

    /// @dev Retrieves the owner of the contract
    /// @return The owner of the contract
    #[external("public")]
    fn get_owner() -> AztecAddress {
        storage.owner.read()
    }

    /// @dev - Creates a new order and increments the order ID
    /// @dev - [NOTE]: a given order_id is retrieved via the get_order_id() in FE + Stored from FE. (Because the order_id is a PublicMutable variable)
    #[external("private")]
    fn create_new_order(order_id: u128, order_block_number: u32) {
        let logistics_order_management = LogisticsOrderManagement::at(context.this_address());

        let msg_sender: AztecAddress = context.msg_sender().unwrap();

        let order_quantity: u128 = 100; // Initial order quantity is set to
        let new_private_order_note = PrivateOrderNote::new(msg_sender, order_id, order_quantity, order_block_number);

        //let current_order_id = storage.order_id.read();
        //let current_order_id = logistics_order_management.get_order_id().call(&mut context);
        
        // @dev - Store the order quantity associated with the order_id
        // @dev - Using the initialize() instead of replace() since there's no existing note for a new order
        storage.order_quantity.at(order_id).initialize(new_private_order_note).emit(msg_sender, MessageDelivery.CONSTRAINED_ONCHAIN);    

        // @dev - Public function: The order_id is incremented internally.
        logistics_order_management.increment_order_id().enqueue(&mut context); // @dev - enqueue() method should be used for a "public" function called inside the private function.
    }

    // @dev - Update an existing order
    #[external("private")] // @dev - [NOTE]: a "private" function will not return any value.
    fn update_existing_order(order_id: u128, new_order_quantity: u128, new_order_block_number: u32) {
        let msg_sender: AztecAddress = context.msg_sender().unwrap();

        let existing_private_order_note = storage.order_quantity.at(order_id).get_note();

        let new_private_order_note = PrivateOrderNote::new(msg_sender, order_id, new_order_quantity, new_order_block_number);

        // @dev - Update an existing order's quantity associated with the order_id
        storage.order_quantity.at(order_id).replace(|existing_private_order_note| new_private_order_note).emit(msg_sender, MessageDelivery.CONSTRAINED_ONCHAIN);
    }

    /// @dev Retrieves the current order ID
    /// @dev - This return value can be retrieved on FE - since the "order_id" is a PublicMutable variable.
    /// @return The current order ID
    #[external("public")]
    #[view]
    fn get_order_id() -> u128 {
        storage.order_id.read()
    }

    /// @dev - Increments the order ID
    #[external("public")] // @dev - [NOTE]: .write()/.read() methods can be used in "public" functions.
    #[internal]
    fn increment_order_id() {
        let current_order_id: u128 = storage.order_id.read();
        storage.order_id.write(current_order_id + 1);
    }
}
