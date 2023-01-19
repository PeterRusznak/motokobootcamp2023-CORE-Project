import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Time "mo:base/Time";
import Debug "mo:base/Debug";



import Hash "mo:base/Hash";
import Option "mo:base/Option";
import Principal "mo:base/Principal";


actor {
    //My discord is: iri#1598
    //Feel free to DM me any question.
    
    type Proposal = {
        id:Int;
        text:Text;
        principal:Principal;
        for_:Nat;
        against:Nat;
    };

    stable var persistor : [(Int, Proposal)] = [];

    let usernames = HashMap.fromIter<Int,Proposal>(persistor.vals(), 10, Int.equal, Int.hash);
    stable var proposalId :Int = 0;
       

    public shared({caller}) func submit_proposal(this_payload : Text) : async {#Ok : Proposal; #Err : Text} {
        Debug.print(debug_show(Time.now())#" Timestamp ");
        var prop:Proposal = {id=proposalId;text=this_payload; principal=caller; for_=0; against=0 };
        usernames.put(proposalId, prop);
        proposalId += 1;
        return #Ok(prop);
    };

    public shared({caller}) func vote(proposal_id : Int, yes_or_no : Bool) : async {#Ok : (Nat, Nat); #Err : Text} {
        var pr: ?Proposal = usernames.get(proposal_id);         
        switch(pr) {
            case(null) {
                return #Err("There is no such proposal");            
            };
            case(?pr) {          
                var for_ :Nat = pr.for_;
                var against :Nat = pr.against;
                if(yes_or_no){
                    for_ := 1000
                }else{
                    against:= 1000;
                };               
                var prop:Proposal = {id=pr.id;text=pr.text; principal=pr.principal; for_= for_; against=against };
                usernames.put(pr.id, prop);                    
                    
                return #Ok(prop.for_, prop.against);            
            };          
          };        
    };

    public query func get_proposal(id : Int) : async ?Proposal {
        usernames.get(id);        
    };
    
    public query func get_all_proposals() : async [(Int, Proposal)] {
        return Iter.toArray<(Int,Proposal)>(usernames.entries());        
    };

    system func preupgrade() {
        persistor := Iter.toArray(usernames.entries());
    };

    system func postupgrade() {
        persistor := [];
    };
};