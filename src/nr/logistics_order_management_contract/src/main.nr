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
    #[derive(Eq, Packable)]
    #[note]
    //#[custom_note]
    pub struct PrivateOrderNote {
        owner: AztecAddress,
        //order_id: u128,
        order_quantity: u128,
        randomness: Field,
    }

    impl PrivateOrderNote {
        pub fn new(owner: AztecAddress, order_quantity: u128) -> Self {
            let randomness = unsafe { random() };
            PrivateOrderNote { 
                owner,
                //order_id: current_order_id,
                order_quantity, 
                randomness 
            }
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
    fn create_new_order(order_id:u128) {
        let logistics_order_management = LogisticsOrderManagement::at(context.this_address());

        // @dev - Public function: The order_id is incremented internally.
        logistics_order_management.order_internal();
        //logistics_order_management.order_internal().enqueue(&mut context); // @dev - enqueue() method should be used for a "public" function.

        let msg_sender: AztecAddress = context.msg_sender().unwrap();

        let order_quantity: u128 = 100; // Initial order quantity is set to
        let new_private_order_note = PrivateOrderNote::new(msg_sender, order_quantity);

        //let current_order_id = storage.order_id.read();
        //let current_order_id = logistics_order_management.get_order_id();
        
        // @dev - Store the order quantity associated with the caller's address (msg_sender)
        storage.order_quantity.at(order_id).replace(|_old_private_order_note| new_private_order_note).emit(msg_sender, MessageDelivery.CONSTRAINED_ONCHAIN);    
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
    fn order_internal() {
        let current_order_id: u128 = storage.order_id.read();
        storage.order_id.write(current_order_id + 1);
    }
}
