package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"time"
	"hash/fnv"
  "github.com/hyperledger/fabric-chaincode-go/shim"
  pb "github.com/hyperledger/fabric-protos-go/peer"
)

// SimpleChaincode example simple Chaincode implementation
type SimpleChaincode struct {
}

type wallet struct {
	ObjectType string `json:"docType"` //docType is used to distinguish the various types of objects in state database
	WalletID string `json:"walletID"`
	OwnerID string `json:"ownerID"`
	OwnerType string `json:"ownerType"` //admin, client or factchecker
	OrgID string `json:"orgID"`
	OwnerName string `json:"ownerName"`
	Balance int `json:"wallet"`
}
type claim struct {
    ObjectType string `json:"docType"` //docType is used to distinguish the various types of objects in state database
		ClaimID string `json:"claimID"`
		Status string `json:"status"` //created,pendingFactcheckAssessment,factchecked,expired
		StatusUpdatedAt string `json:"statusUpdatedAt"`
		Org string `json:"org"` //argv[0]
		ClaimOnOrgID string `json:"claimOnOrgID"` //argv[1]
		ClientID string `json:"clientID"` //argv[2]
		ClaimTitle string `json:"claimTitle"` //argv[3]
		ClaimURLOnOrg string `json:"claimURLOnOrg"` //argv[4]
// From this point, arguments are optional
//This is related to the reward for factchecking
		DatePublished string `json:"datePublished"` //automated timestamp
		Deadline string `json:"deadline"` //argv[5]
    RewardAmount string `json:"rewardAmount"` //argv[7]
		Conditions string `json:"conditions"` //argv[8]
//This part includes addtional details about the claim
		ClaimURL string `json:"claimURL"` //argv[9]
    Description string `json:"description"` //argv[10]
    ClaimSource string `json:"claimSource"` //argv[11]
    ClaimMedium string `json:"claimMedium"` //argv[12]
		HasImage string `json:"hasImage"` //argv[13]
    HasVideo string `json:"hasVideo"` //argv[14]
    HasText string `json:"hasText"` //argv[15]
    Tags string `json:"tags"` //argv[16]
}

type factcheck struct {
    ObjectType string `json:"docType"` //docType is used to distinguish the various types of objects in state database
		FactcheckID string `json:"factcheckID"`
		Status string `json:"status"` //created,approved,rejected
		StatusUpdateComments string `json:"statusUpdateComments"`
		StatusUpdatedAt string `json:"statusUpdatedAt"`
		Org string `json:"org"` //argv[0]
    FactcheckIDOnOrg string `json:"factcheckOnOrgID"` //argv[1]
		FactcheckerID string `json:"factcheckerID"` //argv[2]
		ClaimID string `json:"claimID"` //argv[3]
    RatingLabel string `json:"ratingLabel"` //argv[4]
// From this point, arguments are optional
		DatePublished string `json:"datePublished"` //automated timestamp
		FactcheckURLOnOrg string `json:"factcheckURLOnOrg"` //argv[5]
    WorstRating string `json:"worstRating"` //argv[6]
		BestRating string `json:"bestRating"` //argv[7]
		Rating string `json:"rating"` //argv[8]
		ImgLogo string `json:"imgLogo"` //argv[9]
		ImgReviewStarted string `json:"imgReviewStarted"` //argv[10]
		ImgOld string `json:"imgOld"` //argv[11]
		ImgForensiDiscrepency string `json:"imgForensiDiscrepency"` //argv[12]
		ImgMetadataDiscrepency string `json:"imgMetadataDiscrepency"` //argv[13]
		ImgLogicalDiscrepency string `json:"imgLogicalDiscrepency"` //argv[14]
		NoteImgOld string `json:"noteImgOld"` //argv[15]
		NoteImgForensiDiscrepency string `json:"noteImgForensiDiscrepency"` //argv[16]
		NoteImgMetadataDiscrepency string `json:"noteImgMetadataDiscrepency"` //argv[17]
		NoteImgLogicalDiscrepency string `json:"noteImgLogicalDiscrepency"` //argv[18]
		VidReviewStarted string `json:"vidReviewStarted"` //argv[19]
		VidOld string `json:"vidOld"` //argv[20]
		VidForensiDiscrepency string `json:"vidForensiDiscrepency"` //argv[21]
		VidMetadataDiscrepency string `json:"vidMetadataDiscrepency"` //argv[22]
		VidAudioDiscrepency string `json:"vidAudioDiscrepency"` //argv[23]
		VidLogicalDiscrepency string `json:"vidLogicalDiscrepency"` //argv[24]
		NoteVidOld string `json:"noteVidOld"` //argv[25]
		NoteVidForensiDiscrepency string `json:"noteVidForensiDiscrepency"` //argv[26]
		NoteVidMetadataDiscrepency string `json:"noteVidMetadataDiscrepency"` //argv[27]
		NoteVidAudioDiscrepency string `json:"noteVidAudioDiscrepency"` //argv[28]
		NoteVidLogicalDiscrepency string `json:"noteVidLogicalDiscrepency"` //argv[29]
		TxtReviewStarted string `json:"txtReviewStarted"` //argv[30]
		TxtUnreliableNewsContent string `json:"txtUnreliableNewsContent"` //argv[31]
		TxtInsufficientVerifiableSrcs string `json:"txtInsufficientVerifiableSrcs"` //argv[32]
		TxtHasClickbait string `json:"txtHasClickbait"` //argv[33]
		TxtPoorLanguage string `json:"txtPoorLanguage"` //argv[34]
		TxtCrowdsDistanceDiscrepency string `json:"txtCrowdsDistanceDiscrepency"` //argv[35]
		TxtAuthorOffersLittleEvidence string `json:"txtAuthorOffersLittleEvidence"` //argv[36]
		TxtReliableSourcesDisapprove string `json:"txtReliableSourcesDisapprove"` //argv[37]
		NoteTxtUnreliableNewsContent string `json:"noteTxtUnreliableNewsContent"` //argv[38]
		NoteTxtInsufficientVerifiableSrcs string `json:"noteTxtInsufficientVerifiableSrcs"` //argv[39]
		NoteTxtHasClickbait string `json:"noteTxtHasClickbait"` //argv[40]
		NoteTxtPoorLanguage string `json:"noteTxtPoorLanguage"` //argv[41]
		NoteTxtCrowdsDistanceDiscrepency string `json:"noteTxtCrowdsDistanceDiscrepency"` //argv[42]
		NoteTxtAuthorOffersLittleEvidence string `json:"noteTxtAuthorOffersLittleEvidence"` //argv[43]
		NoteTxtReliableSourcesDisapprove string `json:"noteTxtReliableSourcesDisapprove"` //argv[44]
}

// ===================================================================================
// Main
// ===================================================================================
func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}
}

// Init initializes chaincode
// ===========================
func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

// Invoke - Our entry point for Invocations
// ========================================
func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	fmt.Println("invoke is running " + function)

	// Handle different functions
	if function == "registerWallet" { //register a wallet (for clients, admins and factcheckers)
		return t.registerWallet(stub, args)
	} else if function == "addToClientWallet" { //deposit funds to wallet
			return t.addToClientWallet(stub, args)
	} else if function == "addClaim" { //delete a claim
			return t.addClaim(stub, args)
	} else if function == "addFactcheck" { //add a factcheck
		return t.addFactcheck(stub, args)
	} else if function == "assessFactcheck" { //add a factcheck
		return t.assessFactcheck(stub, args)
	} else if function == "readRecord" { //read a claim, factcheck or wallet
		return t.readRecord(stub, args)
//	} else if function == "deleteRecord" { //delete a factcheck
//		return t.deleteRecord(stub, args)
	} else if function == "queryRecords" { //find factchecks for org X using rich query
		return t.queryRecords(stub, args)
	} else if function == "queryRecordsByOrg" { //find factchecks for org X using rich query
		return t.queryRecordsByOrg(stub, args)
	} else if function == "getHistoryForRecord" { //get history of values for a factcheck
		return t.getHistoryForRecord(stub, args)
	} else if function == "getRecordsByRange" { //get factchecks based on range query
		return t.getRecordsByRange(stub, args)
	} else if function == "getRecordsByRangeWithPagination" {
		return t.getRecordsByRangeWithPagination(stub, args)
	} else if function == "queryRecordsWithPagination" {
		return t.queryRecordsWithPagination(stub, args)
	}

	fmt.Println("invoke did not find func: " + function) //error
	return shim.Error("Received unknown function invocation")
}
// ============================================================
// hash - creates a unique 20-number ID for different records
// ============================================================
func hash(s string) string {
        h := fnv.New64a()
        h.Write([]byte(s))
        return strconv.FormatUint(uint64(h.Sum64()),10)
}

func addToWallet(stub shim.ChaincodeStubInterface, ownerType string, walletID string, amount int) pb.Response {
	var err error
	var walletJSON wallet

	walletAsBytes, err := stub.GetState(walletID)
	if err != nil {
		return shim.Error("Failed to get client: " + err.Error())
	}
	if walletAsBytes==nil {
		return shim.Error("The wallet " +walletID+" was not found.")
	}

	err = json.Unmarshal([]byte(walletAsBytes), &walletJSON)
	if err != nil {
		return shim.Error("Failed to unmarshal wallet record: "+ err.Error())
	}

	if walletJSON.OwnerType!=ownerType {
		return shim.Error("Error: Type of owner mismatch. Cannot deposit funds.")
	}
	if amount<0 && walletJSON.Balance<amount {
			return shim.Error("Balance insufficient.")
		}
	walletJSON.Balance = walletJSON.Balance+amount

	walletJSONasBytes, err := json.Marshal(walletJSON)
	if err != nil {
		return shim.Error(err.Error())
	}
	err = stub.PutState(walletJSON.WalletID, walletJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success([]byte("Updated balance successfully: "+string(walletJSONasBytes)))
}

// ============================================================
// registerWallet - create a new wallet for a client, admin or factchecker
// ============================================================
func (t *SimpleChaincode) registerWallet(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	var groupSymbol="F"

	if len(args[0]) <= 0 {
		return shim.Error("1st argument (type) is missing, it can be 'admin','client', or 'factchecker'")
	}
	if args[0]!="admin" && args[0]!="client" && args[0]!="factchecker" {
		return shim.Error("1st argument can either be 'admin','client', or 'factchecker'")
	}
	if len(args[1]) <= 0 {
		return shim.Error("2nd argument (org ID) must be provided")
	}
	if len(args[2]) <= 0 {
		return shim.Error("3rd argument (user ID) must be provided")
	}
	if len(args[3])<=0 {
		args[3]=""
	}
	if args[0]=="admin" { groupSymbol="A"
	} else if args[0]=="client" { groupSymbol="C"
	}

	encodedID := hash(args[1]+"-"+args[2])

	var wlt wallet
	wlt.ObjectType = "wallet"
  wlt.WalletID = "W"+groupSymbol+encodedID //a unique id representig the hash of the url where the claim is found (identifier)
	wlt.OwnerType = args[0] //format of UTC datetime: YYYY-MM-DD HH:MM:SS
	wlt.OrgID = args[1]
	wlt.OwnerID = encodedID
	wlt.OwnerName = args[3]
	wlt.Balance = 0

	walletAsBytes, err := stub.GetState(wlt.WalletID)
	if err != nil {
		return shim.Error("Failed to register wallet: " + err.Error())
	} else if walletAsBytes != nil {
		return shim.Error("This wallet already exists: " + wlt.WalletID)
	}

	walletJSONasBytes, err := json.Marshal(wlt)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(wlt.WalletID, walletJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success([]byte("Registered wallet successfully: "+string(walletJSONasBytes)))
}

// ============================================================
// addToClientWallet - deposit an amount to a client's wallet
// ============================================================
func (t *SimpleChaincode) addToClientWallet(stub shim.ChaincodeStubInterface, args []string) pb.Response {
//	var err error

	if len(args[0]) <= 0 {
		return shim.Error("1st argument (wallet ID) is missing.")
	}
	if len(args[1]) <= 0 {
		return shim.Error("2nd argument (amount to add) is missing")
	}

	amountToAdd, err := strconv.Atoi(args[1])
	if err != nil {
		return shim.Error("Error: " + err.Error())
	}

	fmt.Println(args[0]+args[1])
	return addToWallet(stub,"client",args[0],amountToAdd)
}

// ============================================================
// addClaim - create a new claim, store into chaincode state
// ============================================================
func (t *SimpleChaincode) addClaim(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	var clientWalletJSON wallet

	groupSymbol := "C" //Only clients are allowed to add claims

	if len(args[0]) <= 0 {
		return shim.Error("1st argument (claim org) is missing")
	}
	if len(args[1]) <= 0 {
		return shim.Error("2nd argument (claim id) is missing")
	}
	if len(args[2]) <= 0 {
		return shim.Error("2nd argument (client id) is missing")
	}
	if len(args[3]) <= 0 {
		return shim.Error("3rd argument (claim title) is missing")
	}
	if len(args[4]) <= 0 {
		return shim.Error("4th argument (claim url on org) is missing")
	}

	sz := len(args)
	for i := sz; i <=15; i++ { args = append(args,"") }

	encodedID := hash(args[0]+"-"+args[2]+"-"+args[4])
	encodedID2 := hash(args[0]+"-"+args[2])

	tm := time.Now().UTC()
	currentTime := fmt.Sprintf("%d-%02d-%02d %02d:%02d:%02d",tm.Year(), tm.Month(), tm.Day(),tm.Hour(), tm.Minute(), tm.Second())

	var clm claim
	clm.ObjectType = "claim"
  clm.ClaimID = "C"+encodedID //a unique id representig the hash of the url where the claim is found (identifier)
	clm.Status = "created"
	clm.StatusUpdatedAt = ""
	clm.DatePublished = currentTime //format of UTC datetime: YYYY-MM-DD HH:MM:SS
	clm.Org = args[0]
	clm.ClaimOnOrgID = args[1]
	clm.ClientID = encodedID2 // a composite hash created from args[0] (org) and args[2] (user id)
	clm.ClaimTitle = args[3]
	clm.ClaimURLOnOrg = args[4]
// From this point, arguments are optional
	clm.Deadline = args[5]
	clm.RewardAmount = args[6]
	clm.Conditions = args[7]
	clm.ClaimURL = args[8]
	clm.Description = args[9]
	clm.ClaimSource = args[10]
	clm.ClaimMedium = args[11]
	clm.HasImage = args[12]
	clm.HasVideo = args[13]
	clm.HasText = args[14]
	clm.Tags = args[15]

	// ==== Check if claim already exists and deadline is valid ====
	if clm.Deadline!="" {
		ex, err :=time.Parse("2006-01-02 15:04",clm.Deadline)
		if err != nil {
			return shim.Error("Error in parsing deadline: "+err.Error())
		}
		if ex.Before(tm) {
			return shim.Error("Deadline cannot be in the past.")
		}
	}

	clientWalletAsBytes, err := stub.GetState("W"+groupSymbol+clm.ClientID)
	if err != nil {
		return shim.Error("Failed to get client wallet: " + err.Error())
	}
	if clientWalletAsBytes == nil {
		return shim.Error("Could not find the client's wallet: W"+clm.ClaimID)
	}

	if (len(clm.RewardAmount)>0) {
			rewardAmnt,err := strconv.Atoi(clm.RewardAmount)
				if err != nil {
			return shim.Error("Error in parsing reward amount: "+err.Error())
			err = json.Unmarshal([]byte(clientWalletAsBytes), &clientWalletJSON)
			if err != nil {
				return shim.Error("Failed to unmarshal wallet record: "+ err.Error())
			}
			if clientWalletJSON.Balance<rewardAmnt {
				return shim.Error("The wallet balance is insufficient: "+ err.Error())
			}
		}
	} else {
		clm.RewardAmount="0"
	}

	claimAsBytes, err := stub.GetState(clm.ClaimID)
	if err != nil {
		return shim.Error("Failed to get claim: " + err.Error())
	} else if claimAsBytes != nil {
		return shim.Error("This claim already exists: " + clm.ClaimID)
	}

	claimJSONasBytes, err := json.Marshal(clm)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(clm.ClaimID, claimJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

//index1: search claim ratings based on org:
	indexOrg := "claimid~org"
	ClaimIDOrgIndexKey, err := stub.CreateCompositeKey(indexOrg, []string{clm.ClaimID, clm.Org})
	if err != nil {
		return shim.Error(err.Error())
	}
	value := []byte{0x00}
	stub.PutState(ClaimIDOrgIndexKey, value)

	// ==== claim saved and indexed. Return success ====
	fmt.Println("- end init claim")
	return shim.Success([]byte("Added successfully: "+string(claimJSONasBytes)))
}

// ============================================================
// addFactcheck - create a new factcheck, store into chaincode state
// ============================================================
func (t *SimpleChaincode) addFactcheck(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	var claimJSON claim

	groupSymbol := "F" //only factcheckers are allowed to add factchecks

	if len(args[0]) <= 0 {
		return shim.Error("1st argument (factcheck org) is missing")
	}
	if len(args[1]) <= 0 {
		return shim.Error("2nd argument (factcheck id) is missing")
	}
	if len(args[2]) <= 0 {
		return shim.Error("3rd argument (factchecker id) is missing")
	}
	if len(args[3]) <= 0 {
		return shim.Error("4th argument (claim id) is missing")
	}
	if len(args[4]) <= 0 {
		return shim.Error("5th argument (rating) is missing")
	}
	if len(args[5]) <= 0 {
		return shim.Error("6th argument (factcheck URL on Org website) is missing")
	}

	encodedID2 := hash(args[0]+"-"+args[2])

	tm := time.Now().UTC()
	currentTime := fmt.Sprintf("%d-%02d-%02d %02d:%02d:%02d",tm.Year(), tm.Month(), tm.Day(),tm.Hour(), tm.Minute(), tm.Second())

	// ==== confirm first that the claim exists ====

	claimAsBytes, err := stub.GetState(args[3])
	if err != nil {
		return shim.Error("Error: "+ err.Error())
	} else if claimAsBytes == nil {
		return shim.Error("Could not find the claim with id ("+args[3]+") you are factchecking")
	}

	FactcheckerWallet, err := stub.GetState("W"+groupSymbol+encodedID2)
	if err != nil {
		return shim.Error("Failed to get wallet of factchecker: " + err.Error())
	}
	if FactcheckerWallet==nil {
		return shim.Error("Could not find the wallet of factchecker: " + err.Error())
		}

	err = json.Unmarshal([]byte(claimAsBytes), &claimJSON)
	if err != nil {
		return shim.Error("Failed to unmarshal claim record: "+ err.Error())
	}

	if claimJSON.Deadline!="" {
		ex, err :=time.Parse("2006-01-02 15:04",claimJSON.Deadline)
		if err != nil {
			return shim.Error("Error in parsing deadline: "+err.Error())
		}
		if ex.Before(tm) {
			return shim.Error("Deadline has already passed.")
		}
	}

	if claimJSON.Status!="created" {
			return shim.Error("This claim is marked as 'completed' and no longer needs factchecks.")
	}

	sz := len(args)
	for i := sz; i <=44; i++ { args = append(args,"") }

	fmt.Println("- start init factcheck")

	encodedID := hash(args[0]+"-"+args[2]+"-"+args[5])

	var fc factcheck
	fc.ObjectType = "factcheck"
	fc.FactcheckID = "F"+encodedID //a unique id representig the hash of the url where the factcheck is found (identifier)
	fc.Status = "created" //can be 'created' or 'factchecked'
	fc.StatusUpdateComments = ""
	fc.StatusUpdatedAt = ""
	fc.DatePublished = currentTime
	fc.Org = args[0]
	fc.FactcheckIDOnOrg = args[1]
	fc.FactcheckerID = encodedID2 //args[2] is the unique user id in the org
	fc.ClaimID = args[3]
	fc.RatingLabel = args[4]
	fc.FactcheckURLOnOrg = args[5]
// From this point, arguments are optional
	fc.WorstRating = args[6]
	fc.BestRating = args[7]
	fc.Rating = args[8]
	fc.ImgLogo = args[9]
	fc.ImgReviewStarted = args[10]
	fc.ImgOld = args[11]
	fc.ImgForensiDiscrepency = args[12]
	fc.ImgMetadataDiscrepency = args[13]
	fc.ImgLogicalDiscrepency = args[14]
	fc.NoteImgOld = args[15]
	fc.NoteImgForensiDiscrepency = args[16]
	fc.NoteImgMetadataDiscrepency = args[17]
	fc.NoteImgLogicalDiscrepency = args[18]
	fc.VidReviewStarted = args[19]
	fc.VidOld = args[20]
	fc.VidForensiDiscrepency = args[21]
	fc.VidMetadataDiscrepency = args[22]
	fc.VidAudioDiscrepency = args[23]
	fc.VidLogicalDiscrepency = args[24]
	fc.NoteVidOld = args[25]
	fc.NoteVidForensiDiscrepency = args[26]
	fc.NoteVidMetadataDiscrepency = args[27]
	fc.NoteVidAudioDiscrepency = args[28]
	fc.NoteVidLogicalDiscrepency = args[29]
	fc.TxtReviewStarted = args[30]
	fc.TxtUnreliableNewsContent = args[31]
	fc.TxtInsufficientVerifiableSrcs = args[32]
	fc.TxtHasClickbait = args[33]
	fc.TxtPoorLanguage = args[34]
	fc.TxtCrowdsDistanceDiscrepency = args[35]
	fc.TxtAuthorOffersLittleEvidence = args[36]
	fc.TxtReliableSourcesDisapprove = args[37]
	fc.NoteTxtUnreliableNewsContent = args[38]
	fc.NoteTxtInsufficientVerifiableSrcs = args[39]
	fc.NoteTxtHasClickbait = args[40]
	fc.NoteTxtPoorLanguage = args[41]
	fc.NoteTxtCrowdsDistanceDiscrepency = args[42]
	fc.NoteTxtAuthorOffersLittleEvidence = args[43]
	fc.NoteTxtReliableSourcesDisapprove = args[44]

	// ==== Check if factcheck already exists ====
	factcheckAsBytes, err := stub.GetState(fc.FactcheckID)
	if err != nil {
		return shim.Error("Failed to get factcheck: " + err.Error())
	} else if factcheckAsBytes != nil {
		return shim.Error("This factcheck already exists: " + fc.FactcheckID)
	}

	// ==== Create factcheck object and marshal to JSON ====

	factcheckJSONasBytes, err := json.Marshal(fc)
	if err != nil {
		return shim.Error(err.Error())
	}

//	fmt.Println("\n\nas bytes: "+factcheckJSONasBytes+"\n\n")
//	fmt.Println("\n\nas string: "+string(factcheckJSONasBytes)+"\n\n")

	// === Save factcheck to state ===
	err = stub.PutState(fc.FactcheckID, factcheckJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

//index1: search factcheck ratings based on org:
	indexRating := "claimid~rating"
	ClaimIDratingIndexKey, err1 := stub.CreateCompositeKey(indexRating, []string{fc.ClaimID, fc.RatingLabel})
	if err1 != nil {
		return shim.Error(err1.Error())
	}
	value1 := []byte{0x00}
	stub.PutState(ClaimIDratingIndexKey, value1)

//index1: search factcheck ids based on org:
	indexFCid := "claimid~fcid"
	ClaimIDfactcheckIDIndexKey, err2 := stub.CreateCompositeKey(indexFCid, []string{fc.ClaimID, fc.FactcheckID})
	if err2 != nil {
		return shim.Error(err2.Error())
	}
	value2 := []byte{0x00}
	stub.PutState(ClaimIDfactcheckIDIndexKey, value2)

	// ==== factcheck saved and indexed. Return success ====
	fmt.Println("- end init factcheck")
	return shim.Success([]byte("Added successfully: "+string(factcheckJSONasBytes)))
//	return shim.Success(nil)
}

// ============================================================
// assessFactcheck - give a particular factcheck an assessment
// ============================================================
func (t *SimpleChaincode) assessFactcheck(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	var factcheckJSON factcheck
	var claimJSON claim

	type FC []struct {
		Key    string `json:"key"`
		Record struct {
			FactcheckerID string `json:"factcheckerID"`
		} `json:"Record"`
	}

	var approvedFactchecks FC

	if len(args[0]) <= 0 {
		return shim.Error("1st argument (Org name) is missing")
	}
	if len(args[1]) <= 0 {
		return shim.Error("2nd argument (FactcheckID) is missing")
	}
	if len(args[2]) <= 0 {
		return shim.Error("3rd argument (user ID in org) must be provided")
	}
	if len(args[3]) <= 0 {
		return shim.Error("4th argument (assessment) must be provided, can be 'approved' or 'rejected'")
	}
	if len(args[4]) <= 0 { 	//args[3] is optional and can be a rationale behind the particular assessment given
		args[4]=""
	}

	if args[3]!="approved" && args[3]!="rejected" {
		return shim.Error("3rd argument can either be 'approved' or 'rejected'")
	}

	AdminID := "A"+hash(args[0]+"-"+args[2])

	AdminWallet, err := stub.GetState("W"+AdminID)
	if err != nil {
		return shim.Error("Failed to get wallet of admin: " + err.Error())
	}
	if AdminWallet == nil {
		return shim.Error("Could not find wallet with ID: W"+AdminID)
	}

	factcheckAsBytes, err := stub.GetState(args[1])
	if err != nil {
		return shim.Error("Failed to get factcheck: " + err.Error())
	} else if factcheckAsBytes == nil {
		return shim.Error("Could not find the factcheck with id ("+args[1]+")!")
	}

	err = json.Unmarshal([]byte(factcheckAsBytes), &factcheckJSON)
	if err != nil {
		return shim.Error("Failed to unmarshal factcheck record: "+ err.Error())
	}

	if factcheckJSON.Status!="created" {
		return shim.Error("This factcheck has already been assessed and was "+factcheckJSON.Status)
	}

	tm := time.Now().UTC()
	currentTime := fmt.Sprintf("%d-%02d-%02d %02d:%02d:%02d",tm.Year(), tm.Month(), tm.Day(),tm.Hour(), tm.Minute(), tm.Second())

	claimAsBytes, err := stub.GetState(factcheckJSON.ClaimID)
	if err != nil {
		return shim.Error("Failed to get claim: " + err.Error())
	}
	err = json.Unmarshal([]byte(claimAsBytes), &claimJSON)
	if err != nil {
		return shim.Error("Failed to unmarshal factcheck record: "+ err.Error())
	}
	if claimJSON.Deadline!="" {
		ex, err :=time.Parse("2006-01-02 15:04",claimJSON.Deadline)
		if err != nil {
			return shim.Error("Error in parsing deadline: "+err.Error())
		}
		if ex.After(tm) {
			return shim.Error("You can only assess factchecks after the passing of the deadline at "+claimJSON.Deadline)
		}
	}
	if claimJSON.Status!="created" {
			return shim.Error("The claim seems to have already been factchecked and marked as 'completed' at "+claimJSON.StatusUpdatedAt)
	}

	factcheckJSON.Status = args[3]
	factcheckJSON.StatusUpdatedAt = currentTime
	factcheckJSON.StatusUpdateComments=args[4]

	factcheckJSONasBytes, err := json.Marshal(factcheckJSON)
	if err != nil {
		return shim.Error(err.Error())
	}

	err = stub.PutState(factcheckJSON.FactcheckID, factcheckJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}
	log:=fmt.Sprintf("Factcheck assessed successfully and was : %s\n%s",args[3],string(factcheckJSONasBytes))

	searchQuery:="{\"selector\":{\"claimID\":\""+factcheckJSON.ClaimID+"\",\"docType\":\"factcheck\",\"status\":\"created\",\"$not\":{\"factcheckID\":\""+factcheckJSON.FactcheckID+"\"}},\"fields\":[\"factcheckID\"]}"

	pendingFactchecks, err := getQueryResultForQueryString(stub,searchQuery)
	if err != nil {
		return shim.Error(err.Error())
	}
	log=log+fmt.Sprintf(" Result of query ("+searchQuery+") is: in string:("+string(pendingFactchecks)+")")

	if (len(pendingFactchecks)>5) {
		return shim.Success([]byte("In order to settle the reward, you need to assess the other remaining factchecks: "+ string(pendingFactchecks)))
	}

	if (args[3]=="approved") {
		searchQuery="{\"selector\":{\"$or\":[{\"factcheckID\":\""+factcheckJSON.FactcheckID+"\"},{\"claimID\":\""+factcheckJSON.ClaimID+"\",\"docType\":\"factcheck\",\"status\":\"approved\"}]},\"fields\":[\"factcheckerID\"]}"
	} else {
		searchQuery="{\"selector\":{\"claimID\":\""+factcheckJSON.ClaimID+"\",\"docType\":\"factcheck\",\"status\":\"approved\"},\"fields\":[\"factcheckerID\"]}"
	}

	resultsIterator, err := stub.GetQueryResult(searchQuery)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	buffer, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return shim.Error(err.Error())
	}

	log=log+" BUFFER="+buffer.String()

	err = json.Unmarshal([]byte(buffer.String()), &approvedFactchecks)
	if err != nil {
		return shim.Error(err.Error())
	}

	var totalApprovedFactchecks int
	var adminShare int
	var fullReward int
	var factcheckerShare int

  totalApprovedFactchecks = len(approvedFactchecks)
	log=log+" total # of approvedFactchecks: ("+strconv.Itoa(totalApprovedFactchecks)+")"
	fullReward, err =strconv.Atoi(claimJSON.RewardAmount)
	if err!=nil {
		return shim.Error("Failed to parse reward amount: "+err.Error())
	}

	if (fullReward>0) {
			log=log+fmt.Sprintf("Settle reward payments:")
			log=log+fmt.Sprintf("Deducting from client wallet WC"+claimJSON.ClientID+" the reward amount of ("+strconv.Itoa(fullReward)+")")
			addToWallet(stub,"client","WC"+claimJSON.ClientID,-1*fullReward)
			adminShare = fullReward/4
			log=log+fmt.Sprintf("Rewarding admin Wallet W"+AdminID+" with "+strconv.Itoa(adminShare)+" (25 percent of "+claimJSON.RewardAmount+")")
			addToWallet(stub,"admin","W"+AdminID,adminShare)
			factcheckerShare = (fullReward-adminShare)/totalApprovedFactchecks
			log=log+fmt.Sprintf("Rewarding "+strconv.Itoa(totalApprovedFactchecks)+" factcheckers with "+strconv.Itoa(factcheckerShare)+" each!")
			for i := 0; i <totalApprovedFactchecks; i++ {
				log=log+fmt.Sprintf("Rewarding Factchecker #"+strconv.Itoa(i+1)+" to wallet WF"+approvedFactchecks[i].Record.FactcheckerID+" ")
				addToWallet(stub,"factchecker","WF"+approvedFactchecks[i].Record.FactcheckerID,factcheckerShare)
			}
	}

	if (args[3]=="approved" || claimJSON.Deadline!="") {
		claimJSON.Status = "completed"
		claimJSON.StatusUpdatedAt = currentTime

		claimJSONasBytes, err := json.Marshal(claimJSON)
		if err != nil {
			return shim.Error(err.Error())
		}

		err = stub.PutState(claimJSON.ClaimID, claimJSONasBytes)
		if err != nil {
			return shim.Error(err.Error())
		}
		return shim.Success([]byte(log+"\nClaim successfully factchecked and rewards (if any) settled: "+string(claimJSONasBytes)))
	}
	return shim.Success([]byte(log+"\nFactcheck rejected! Only when a factcheck is approved would this claim (without a deadline) be completed."))

}

// ===============================================
// readRecords - read a claim or factcheck from chaincode state
// ===============================================
func (t *SimpleChaincode) readRecord(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var id, jsonResp string
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting a record ID (starts with 'C' for claims and 'F' for factchecks)")
	}

	id = args[0]
	valAsbytes, err := stub.GetState(id) //get the claim or factcheck from chaincode state
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get state for record with hash: " + id + "\"}"
		return shim.Error(jsonResp)
	} else if valAsbytes == nil {
		jsonResp = "{\"Error\":\"recod with this hash does not exist: " + id + "\"}"
		return shim.Error(jsonResp)
	}

	return shim.Success(valAsbytes)
}
/* Disabled as an attempt to keep the record accountable and immutable
// ==================================================
// delete - remove a factcheck key/value pair from state
// ==================================================
func (t *SimpleChaincode) deleteRecord(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var jsonResp string
	var recordJSON factcheck
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting an ID (starts with 'C' for claims and 'F' for factchecks) to delete the record")
	}
	recordID := args[0]

	// to maintain the org~name index, we need to read the factcheck first and get its org
	valAsbytes, err := stub.GetState(recordID) //get the factcheck from chaincode state
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to get state for record " + recordID + "\"}"
		return shim.Error(jsonResp)
	} else if valAsbytes == nil {
		jsonResp = "{\"Error\":\"record does not exist: " + recordID + "\"}"
		return shim.Error(jsonResp)
	}

	err = json.Unmarshal([]byte(valAsbytes), &recordJSON)
	if err != nil {
		jsonResp = "{\"Error\":\"Failed to decode JSON of: " + recordID + "\"}"
		return shim.Error(jsonResp)
	}

	err = stub.DelState(recordID) //remove the factcheck from chaincode state
	if err != nil {
		return shim.Error("Failed to delete state:" + err.Error())
	}

// maintain the index
	indexTitle := "org~title"
	orgTitleIndexKey, err := stub.CreateCompositeKey(indexTitle, []string{recordJSON.Org, recordJSON.Title})
	if err != nil {
		return shim.Error(err.Error())
	}

//  Delete index entry to state.
	err = stub.DelState(orgTitleIndexKey)
	if err != nil {
		return shim.Error("Failed to delete state:" + err.Error())
	}
	return shim.Success(nil)
}
*/
func constructQueryResponseFromIterator(resultsIterator shim.StateQueryIteratorInterface) (*bytes.Buffer, error) {
	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	return &buffer, nil
}

func addPaginationMetadataToQueryResults(buffer *bytes.Buffer, responseMetadata *pb.QueryResponseMetadata) *bytes.Buffer {

	buffer.WriteString("[{\"ResponseMetadata\":{\"RecordsCount\":")
	buffer.WriteString("\"")
	buffer.WriteString(fmt.Sprintf("%v", responseMetadata.FetchedRecordsCount))
	buffer.WriteString("\"")
	buffer.WriteString(", \"Bookmark\":")
	buffer.WriteString("\"")
	buffer.WriteString(responseMetadata.Bookmark)
	buffer.WriteString("\"}}]")

	return buffer
}

func (t *SimpleChaincode) getRecordsByRange(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args) < 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	startKey := args[0]
	endKey := args[1]

	resultsIterator, err := stub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	buffer, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return shim.Error(err.Error())
	}

	fmt.Printf("- getRecordsByRange queryResult:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

func (t *SimpleChaincode) queryRecordsByOrg(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args[0]) <= 0 {
		return shim.Error("1st argument (org) is missing")
	}
	if len(args[1]) <= 0 {
		return shim.Error("2nd argument (type 'claim' or 'factcheck') is missing")
	}

	org := args[0]
	recordType := args[1]

	queryString := fmt.Sprintf("{\"selector\":{\"docType\":\"%s\",\"org\":\"%s\"}}", recordType, org)

	queryResults, err := getQueryResultForQueryString(stub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}

func (t *SimpleChaincode) queryRecords(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args[0]) <= 0 {
		return shim.Error("Search query missing!")
	}

	queryString := args[0]

	queryResults, err := getQueryResultForQueryString(stub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}

// =========================================================================================
// getQueryResultForQueryString executes the passed in query string.
// Result set is built and returned as a byte array containing the JSON results.
// =========================================================================================
func getQueryResultForQueryString(stub shim.ChaincodeStubInterface, queryString string) ([]byte, error) {

	fmt.Printf("- getQueryResultForQueryString queryString:\n%s\n", queryString)

	resultsIterator, err := stub.GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	buffer, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return nil, err
	}

	fmt.Printf("- getQueryResultForQueryString queryResult:\n%s\n", buffer.String())

	return buffer.Bytes(), nil
}

func (t *SimpleChaincode) getRecordsByRangeWithPagination(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args) < 4 {
		return shim.Error("Incorrect number of arguments. Expecting 4")
	}

	startKey := args[0]
	endKey := args[1]
	//return type of ParseInt is int64
	pageSize, err := strconv.ParseInt(args[2], 10, 32)
	if err != nil {
		return shim.Error(err.Error())
	}
	bookmark := args[3]

	resultsIterator, responseMetadata, err := stub.GetStateByRangeWithPagination(startKey, endKey, int32(pageSize), bookmark)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	buffer, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return shim.Error(err.Error())
	}

	bufferWithPaginationInfo := addPaginationMetadataToQueryResults(buffer, responseMetadata)

	fmt.Printf("- getRecordsByRange queryResult:\n%s\n", bufferWithPaginationInfo.String())

	return shim.Success(buffer.Bytes())
}

func (t *SimpleChaincode) queryRecordsWithPagination(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//   0
	// "queryString"
	if len(args) < 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3")
	}

	queryString := args[0]
	//return type of ParseInt is int64
	pageSize, err := strconv.ParseInt(args[1], 10, 32)
	if err != nil {
		return shim.Error(err.Error())
	}
	bookmark := args[2]

	queryResults, err := getQueryResultForQueryStringWithPagination(stub, queryString, int32(pageSize), bookmark)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}

// =========================================================================================
// getQueryResultForQueryStringWithPagination executes the passed in query string with
// pagination info. Result set is built and returned as a byte array containing the JSON results.
// =========================================================================================
func getQueryResultForQueryStringWithPagination(stub shim.ChaincodeStubInterface, queryString string, pageSize int32, bookmark string) ([]byte, error) {

	fmt.Printf("- getQueryResultForQueryString queryString:\n%s\n", queryString)

	resultsIterator, responseMetadata, err := stub.GetQueryResultWithPagination(queryString, pageSize, bookmark)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	buffer, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return nil, err
	}

	bufferWithPaginationInfo := addPaginationMetadataToQueryResults(buffer, responseMetadata)

	fmt.Printf("- getQueryResultForQueryString queryResult:\n%s\n", bufferWithPaginationInfo.String())

	return buffer.Bytes(), nil
}

func (t *SimpleChaincode) getHistoryForRecord(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args) < 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	recordID := args[0]

	fmt.Printf("- start getHistoryForRecord: %s\n", recordID)

	resultsIterator, err := stub.GetHistoryForKey(recordID)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the factcheck
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		// if it was a delete operation on given key, then we need to set the
		//corresponding value null. Else, we will write the response.Value
		//as-is (as the Value itself a JSON factcheck)
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- getHistoryForRecord returning:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}
