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
      
    type Proposal = {
        id:Int;
        text:Text;
        principal:Principal;
        vote_for:Nat;
        vote_against:Nat;
    };

    stable var persistor : [(Int, Proposal)] = [];

    let usernames = HashMap.fromIter<Int,Proposal>(persistor.vals(), 10, Int.equal, Int.hash);
    stable var proposalId :Int = 0;
       

    public shared({caller}) func submit_proposal(this_payload : Text) : async {#Ok : Proposal; #Err : Text} {
        Debug.print(debug_show(Time.now())#" submit called ");
        var prop:Proposal = {id=proposalId;text=this_payload; principal=caller; vote_for=0; vote_against=0 };
        usernames.put(proposalId, prop);
        proposalId += 1;
        return #Ok(prop);
    };

    public shared({caller}) func vote(proposal_id : Int, yes_or_no : Bool) : async {#Ok : (Nat, Nat); #Err : Text} {
        Debug.print(debug_show(Time.now())#" vote called ");
        var pr: ?Proposal = usernames.get(proposal_id);         
        switch(pr) {
            case(null) {
                return #Err("There is no such proposal");            
            };
            case(?pr) {          
                var vote_for :Nat = pr.vote_for;
                var vote_against :Nat = pr.vote_against;
                if(yes_or_no){
                    vote_for := 1000
                }else{
                    vote_against:= 1000;
                };               
                var prop:Proposal = {id=pr.id;text=pr.text; principal=pr.principal; vote_for= vote_for; vote_against=vote_against };
                usernames.put(pr.id, prop);                    
                    
                return #Ok(prop.vote_for, prop.vote_against);            
            };          
          };        
    };

    public query func get_proposal(id : Int) : async ?Proposal {
        Debug.print(debug_show(Time.now())#" get  called   ");
        usernames.get(id);        
    };
    
    public query func get_all_proposals() : async [(Int, Proposal)] {
        Debug.print(debug_show(Time.now())#" getAll called   ");
        let ret: [(Int, Proposal)] =Iter.toArray<(Int,Proposal)>(usernames.entries()); 
        Debug.print(debug_show(ret)#" Here are the proposals   ");

        return ret;      
    };

    system func preupgrade() {
        persistor := Iter.toArray(usernames.entries());
    };

    system func postupgrade() {
        persistor := [];
    };
};