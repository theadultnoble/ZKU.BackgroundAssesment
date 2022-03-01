// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract Ballot {
    struct Voter {
        uint weight; //weight is accumulated by delegation
        bool voted;
        address delegate;
        uint vote; //index of the voted proposal
    }

    //This is a type of a single proposal.
    struct Proposal {
        bytes32 name; 
        uint voteCount;
    }
    // 
    address public chairperson;

    //stores a 'Voter' struct for each possible address.
    mapping(address => Voter) public voters;

    //A dynamically-sized array of 'Proposal' structs.
    Proposal[] public proposals;

    ///Create a new Ballot to choose one of 'proposalNames'
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight =1;
        //For each of the provided proposal names,
        //create new proposal object and add it to the array.
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // Give `voterArray` the right to vote.
    // May only be called by `chairperson`.
    function giveRightToVote(address[] memory voterArray) external  {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        );
        ///For each of the provided voter addresses,
        //create a voter object and add it to the array.
        //reduces the number of times function needs to called hereby reducing gas.
        for (uint i = 0; i < voterArray.length; i++) {

            //if any require statement evaluates to false
            //execution terminates and all
            // changes to the state and to Ether balances
            // are reverted.
            //I removed the require statement to check if address has 
            //already voted as it's being chceked in vote function too.

            require(voters[voterArray[i]].weight == 0);

            voters[voterArray[i]].weight = 1;
            }

    }

    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");

        require(to !=msg.sender, "self-delegation disallowed.");
        //...{fill up}

        while (voters[to].delegate != address(0)){
            to = voters[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    /// Give your vote (including votes delegated to you)
    // to proposal 'proposals[proposal].name'.
    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0,"No right to vote" );
        require(!sender.voted, "Already voted");
        sender.voted = true;
        sender.vote = proposal;

        // If `proposal` is out of the range of the array,
        // revert all changes.
        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public view 
            returns (uint winningProposal_)
    {
         uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() external view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }

    

}