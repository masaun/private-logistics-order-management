use aztec::macros::aztec;
pub mod test;

#[aztec]
pub contract LogisticsOrderManagement {
    // aztec library imports
    use aztec::{
        macros::{functions::{external, initializer, internal, view}, storage::storage},
        protocol_types::address::AztecAddress,
        state_vars::{PublicImmutable, PublicMutable},
    };

    // @param owner The address of the owner
    // @param counter A numerical value
    #[storage]
    struct Storage<Context> {
        owner: PublicImmutable<AztecAddress, Context>,
        order_id: PublicMutable<u128, Context>,
        counter: PublicMutable<u128, Context>,
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
    #[external("private")]
    fn create_new_order() {
        LogisticsOrderManagement::at(context.this_address()).order_internal().enqueue(&mut context);
    }

    /// @dev Retrieves the current order ID
    /// @return The current order ID
    #[external("public")]
    #[view]
    fn get_order_id() -> u128 {
        storage.order_id.read()
    }

    /// @dev - Increments the order ID
    #[external("private")]
    #[internal]
    fn order_internal() {
        let current_order_id = storage.order_id.read();
        storage.order_id.write(current_order_id + 1);
    }
}
