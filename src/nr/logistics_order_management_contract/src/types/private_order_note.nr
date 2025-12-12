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
        PublicImmutable, PublicMutable, DelayedPublicMutable,
        PrivateImmutable, PrivateMutable, PrivateSet, 
        Map
    },
    oracle::random::random,
    messages::message_delivery::MessageDelivery
};


/****************************************
 *   @notice - Notes and Custom Notes   *
 ****************************************/

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