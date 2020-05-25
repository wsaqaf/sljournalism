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

type client struct {
	ObjectType string `json:"docType"` //docType is used to distinguish the various types of objects in state database
	OrgID string `json:"orgID"`
	ClientID string `json:"clientID"`
	Balance int `json:"wallet"`
}
type admin struct {
	ObjectType string `json:"docType"` //docType is used to distinguish the various types of objects in state database
	OrgID string `json:"orgID"`
	adminID string `json:"orgID"`
	Balance int `json:"wallet"`
}
type factchecker struct {
	ObjectType string `json:"docType"` //docType is used to distinguish the various types of objects in state database
	OrgID string `json:"orgID"`
	FactcheckerID string `json:"factcheckerID"`
	Balance int `json:"wallet"`
}
type admin_assessment struct {
	ObjectType string `json:"docType"` //docType is used to distinguish the various types of objects in state database
	AssessmentID string `json:"assessmentID"`
	OrgID string `json:"orgID"`
	adminID string `json:"orgID"`
	FactcheckID string `json:"factcheckID"`
	Assessment string `json:"assessment"` //approve or reject
	Rationale string `json:"rationale"`
	DatePublished string `json:"datePublished"`
}
type claim struct {
    ObjectType string `json:"docType"` //docType is used to distinguish the various types of objects in state database
		ClaimID string `json:"claimID"`
		Org string `json:"org"` //argv[0]
		Claim_on_orgID string `json:"claim_on_orgID"` //argv[1]
		ClientID string `json:"clientID"` //argv[2]
		Claim_title string `json:"claim_title"` //argv[3]
		Claim_url_on_org string `json:"claim_url_on_org"` //argv[4]
// From this point, arguments are optional
//This is related to the reward for factchecking
		DatePublished string `json:"datePublished"` //automated timestamp
		Expiry_date string `json:"expiry_date"` //argv[5]
    Reward_amount string `json:"reward_amount"` //argv[6]
		Conditions string `json:"conditions"` //argv[7]
//This part includes addtional details about the claim
		Claim_url string `json:"claim_url"` //argv[8]
    Description string `json:"description"` //argv[9]
    Claim_source string `json:"claim_source"` //argv[10]
    Claim_medium string `json:"claim_medium"` //argv[11]
		Has_image string `json:"has_image"` //argv[12]
    Has_video string `json:"has_video"` //argv[13]
    Has_text string `json:"has_text"` //argv[14]
    Tags string `json:"tags"` //argv[15]
}

type factcheck struct {
    ObjectType string `json:"docType"` //docType is used to distinguish the various types of objects in state database
		FactcheckID string `json:"factcheckID"`
		Org string `json:"org"` //argv[0]
    FactcheckID_on_org string `json:"factcheck_on_orgID"` //argv[1]
		FactcheckerID string `json:"factcheckerID"` //argv[2]
		ClaimID string `json:"claimID"` //argv[3]
    Rating_label string `json:"rating_label"` //argv[4]
// From this point, arguments are optional
		DatePublished string `json:"datePublished"` //automated timestamp
		Factcheck_url_on_org string `json:"factcheck_url_on_org"` //argv[5]
    Worst_rating string `json:"worst_rating"` //argv[6]
		Best_rating string `json:"best_rating"` //argv[7]
		Rating string `json:"rating"` //argv[8]
		Img_logo string `json:"img_logo"` //argv[9]
		Img_review_started string `json:"img_review_started"` //argv[10]
		Img_old string `json:"img_old"` //argv[11]
		Img_forensidiscrepency string `json:"img_forensidiscrepency"` //argv[12]
		Img_metadata_discrepency string `json:"img_metadata_discrepency"` //argv[13]
		Img_logical_discrepency string `json:"img_logical_discrepency"` //argv[14]
		Note_img_old string `json:"note_img_old"` //argv[15]
		Note_img_forensidiscrepency string `json:"note_img_forensidiscrepency"` //argv[16]
		Note_img_metadata_discrepency string `json:"note_img_metadata_discrepency"` //argv[17]
		Note_img_logical_discrepency string `json:"note_img_logical_discrepency"` //argv[18]
		Vid_review_started string `json:"vid_review_started"` //argv[19]
		Vid_old string `json:"vid_old"` //argv[20]
		Vid_forensidiscrepency string `json:"vid_forensidiscrepency"` //argv[21]
		Vid_metadata_discrepency string `json:"vid_metadata_discrepency"` //argv[22]
		Vid_audio_discrepency string `json:"vid_audio_discrepency"` //argv[23]
		Vid_logical_discrepency string `json:"vid_logical_discrepency"` //argv[24]
		Note_vid_old string `json:"note_vid_old"` //argv[25]
		Note_vid_forensidiscrepency string `json:"note_vid_forensidiscrepency"` //argv[26]
		Note_vid_metadata_discrepency string `json:"note_vid_metadata_discrepency"` //argv[27]
		Note_vid_audio_discrepency string `json:"note_vid_audio_discrepency"` //argv[28]
		Note_vid_logical_discrepency string `json:"note_vid_logical_discrepency"` //argv[29]
		Txt_review_started string `json:"txt_review_started"` //argv[30]
		Txt_unreliable_news_content string `json:"txt_unreliable_news_content"` //argv[31]
		Txt_insufficient_verifiable_srcs string `json:"txt_insufficient_verifiable_srcs"` //argv[32]
		Txt_has_clickbait string `json:"txt_has_clickbait"` //argv[33]
		Txt_poor_language string `json:"txt_poor_language"` //argv[34]
		Txt_crowds_distance_discrepency string `json:"txt_crowds_distance_discrepency"` //argv[35]
		Txt_author_offers_little_evidence string `json:"txt_author_offers_little_evidence"` //argv[36]
		Txt_reliable_sources_disapprove string `json:"txt_reliable_sources_disapprove"` //argv[37]
		Note_txt_unreliable_news_content string `json:"note_txt_unreliable_news_content"` //argv[38]
		Note_txt_insufficient_verifiable_srcs string `json:"note_txt_insufficient_verifiable_srcs"` //argv[39]
		Note_txt_has_clickbait string `json:"note_txt_has_clickbait"` //argv[40]
		Note_txt_poor_language string `json:"note_txt_poor_language"` //argv[41]
		Note_txt_crowds_distance_discrepency string `json:"note_txt_crowds_distance_discrepency"` //argv[42]
		Note_txt_author_offers_little_evidence string `json:"note_txt_author_offers_little_evidence"` //argv[43]
		Note_txt_reliable_sources_disapprove string `json:"note_txt_reliable_sources_disapprove"` //argv[44]
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
	if function == "addClaim" { //create a new factcheck
		return t.addClaim(stub, args)
	} else if function == "addFactcheck" { //delete a factcheck
		return t.addFactcheck(stub, args)
	} else if function == "readRecord" { //read a factcheck
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

//create a number hash from a unique URL
func hash(s string) string {
        h := fnv.New64a()
        h.Write([]byte(s))
        return strconv.FormatUint(uint64(h.Sum64()),10)
}

// ============================================================
// addClaim - create a new claim, store into chaincode state
// ============================================================
func (t *SimpleChaincode) addToClientBalance(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

	if len(args[0]) <= 0 {
		return shim.Error("1st argument (client ID) is missing.")
	}
	if len(args[1]) <= 0 {
		return shim.Error("2nd argument (amount to add) is missing")
	}
	amount, err := strconv.Atoi(arg[1])
     if err != nil {
			 	 return shim.Error("Error: " + err.Error())
     }
	walletAsBytes, err := stub.GetState(arg[0])
	if err != nil {
		return shim.Error("Failed to get client: " + err.Error())
	}

	err = json.Unmarshal([]byte(walletAsBytes), &walletJSON)
	if err != nil {
		return fmt.Sprintf("Failed to unmarshal wallet record: %s", err.Error())
	}

	walletJSON.Balance = amount+walletJSON.Balance

	walletJSONasBytes, err := json.Marshal(walletJSON)
	if err != nil {
		return shim.Error(err.Error())
	}

//	fmt.Println("\n\nas bytes: "+walletJSONasBytes+"\n\n")
//	fmt.Println("\n\nas string: "+string(walletJSONasBytes)+"\n\n")

	// === Save claim to state ===
	err = stub.PutState(walletJSON.ClientID, walletJSONasBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success([]byte("Updated balance successfully: "+string(walletJSONasBytes)))
//	return shim.Success(nil)
}

// ============================================================
// addClaim - create a new claim, store into chaincode state
// ============================================================
func (t *SimpleChaincode) addClaim(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

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

	tmp_i := hash(args[2]+"-"+args[4])

	t := time.Now().UTC()
	current_time := fmt.Sprintf("%d-%02d-%02d %02d:%02d:%02d",t.Year(), t.Month(), t.Day(),t.Hour(), t.Minute(), t.Second())

	var clm claim
	clm.ObjectType = "claim"
  clm.ClaimID = "C"+tmp_i //a unique id representig the hash of the url where the claim is found (identifier)
	clm.DatePublished = current_time //format of UTC datetime: YYYY-MM-DD HH:MM:SS
	clm.Org = args[0]
	clm.Claim_on_orgID = args[1]
	clm.ClientID = args[2]
	clm.Claim_title = args[3]
	clm.Claim_url_on_org = args[4]
// From this point, arguments are optional
	clm.Expiry_date = args[5]
	clm.Reward_amount = args[6]
	clm.Conditions = args[7]
	clm.Claim_url = args[8]
	clm.Description = args[9]
	clm.Claim_source = args[10]
	clm.Claim_medium = args[11]
	clm.Has_image = args[12]
	clm.Has_video = args[13]
	clm.Has_text = args[14]
	clm.Tags = args[15]

	// ==== Check if claim already exists and expiry_date is valid ====
	if clm.Expiry_date!="" {
		ex, err :=time.Parse("2006-01-02 00:00:00",clm.Expiry_date)
		if err != nil {
			return shim.Error("Error in parsing expiry date: "+err.Error())
		}
		if ex.Before(t) {
			return shim.Error("Expiry date cannot be in the past.")
		}
	}

	claimAsBytes, err := stub.GetState(clm.ClaimID)
	if err != nil {
		return shim.Error("Failed to get claim: " + err.Error())
	} else if claimAsBytes != nil {
		fmt.Println("This claim already exists: " + clm.ClaimID)
		return shim.Error("This claim already exists: " + clm.ClaimID)
	}

	walletAsBytes, err := stub.GetState(arg[2])
	if err != nil {
		return shim.Error("Failed to get factchecker: " + err.Error())
	}

	walletAsBytes, err := stub.GetState(arg[0])
	if err != nil {
		return shim.Error("Failed to get org: " + err.Error())
	}

	// ==== Create claim object and marshal to JSON ====
	claimJSONasBytes, err := json.Marshal(clm)
	if err != nil {
		return shim.Error(err.Error())
	}

//	fmt.Println("\n\nas bytes: "+claimJSONasBytes+"\n\n")
//	fmt.Println("\n\nas string: "+string(claimJSONasBytes)+"\n\n")

	// === Save claim to state ===
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
//	return shim.Success(nil)
}

// ===============================================
// readRecords - read a claim or factcheck from chaincode state
// ===============================================

// ============================================================
// addFactcheck - create a new factcheck, store into chaincode state
// ============================================================
func (t *SimpleChaincode) addFactcheck(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error

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

	t := time.Now().UTC()
	current_time := fmt.Sprintf("%d-%02d-%02d %02d:%02d:%02d",t.Year(), t.Month(), t.Day(),t.Hour(), t.Minute(), t.Second())

	// ==== confirm first that the claim exists ====

	claimAsBytes, err := stub.GetState(args[3])
	if err != nil {
		return fmt.Sprintf("Error: %s", err.Error())
	} else if claimAsBytes == nil {
		return fmt.Sprintf("Could not find the claim with id (%s) you are factchecking", arg[3])
	}

	walletAsBytes, err := stub.GetState(arg[2])
	if err != nil {
		return shim.Error("Failed to get factchecker: " + err.Error())
	}

	err = json.Unmarshal([]byte(claimAsBytes), &claimJSON)
	if err != nil {
		return fmt.Sprintf("Failed to unmarshal claim record: %s", err.Error())
	}

	if claimJSON.Expiry_date!="" {
		ex, err :=time.Parse("2006-01-02 00:00:00",claimJSON.Expiry_date)
		if err != nil {
			return shim.Error("Error in parsing expiry date: "+err.Error())
		}
		if ex.Before(t) {
			return shim.Error("Expiry date has already passed.")
		}
	}

	sz := len(args)
	for i := sz; i <=44; i++ { args = append(args,"") }

	fmt.Println("- start init factcheck")

	tmp_i := hash(args[2]+"-"+args[5])

	var fc factcheck
	fc.ObjectType = "factcheck"
	fc.FactcheckID = "F"+tmp_i //a unique id representig the hash of the url where the factcheck is found (identifier)
	fc.DatePublished = current_time
	fc.Org = args[0]
	fc.FactcheckID_on_org = args[1]
	fc.FactcheckerID = args[2]
	fc.ClaimID = args[3]
	fc.Rating_label = args[4]
	fc.Factcheck_url_on_org = args[5]
// From this point, arguments are optional
	fc.Worst_rating = args[6]
	fc.Best_rating = args[7]
	fc.Rating = args[8]
	fc.Img_logo = args[9]
	fc.Img_review_started = args[10]
	fc.Img_old = args[11]
	fc.Img_forensidiscrepency = args[12]
	fc.Img_metadata_discrepency = args[13]
	fc.Img_logical_discrepency = args[14]
	fc.Note_img_old = args[15]
	fc.Note_img_forensidiscrepency = args[16]
	fc.Note_img_metadata_discrepency = args[17]
	fc.Note_img_logical_discrepency = args[18]
	fc.Vid_review_started = args[19]
	fc.Vid_old = args[20]
	fc.Vid_forensidiscrepency = args[21]
	fc.Vid_metadata_discrepency = args[22]
	fc.Vid_audio_discrepency = args[23]
	fc.Vid_logical_discrepency = args[24]
	fc.Note_vid_old = args[25]
	fc.Note_vid_forensidiscrepency = args[26]
	fc.Note_vid_metadata_discrepency = args[27]
	fc.Note_vid_audio_discrepency = args[28]
	fc.Note_vid_logical_discrepency = args[29]
	fc.Txt_review_started = args[30]
	fc.Txt_unreliable_news_content = args[31]
	fc.Txt_insufficient_verifiable_srcs = args[32]
	fc.Txt_has_clickbait = args[33]
	fc.Txt_poor_language = args[34]
	fc.Txt_crowds_distance_discrepency = args[35]
	fc.Txt_author_offers_little_evidence = args[36]
	fc.Txt_reliable_sources_disapprove = args[37]
	fc.Note_txt_unreliable_news_content = args[38]
	fc.Note_txt_insufficient_verifiable_srcs = args[39]
	fc.Note_txt_has_clickbait = args[40]
	fc.Note_txt_poor_language = args[41]
	fc.Note_txt_crowds_distance_discrepency = args[42]
	fc.Note_txt_author_offers_little_evidence = args[43]
	fc.Note_txt_reliable_sources_disapprove = args[44]

	// ==== Check if factcheck already exists ====
	factcheckAsBytes, err := stub.GetState(fc.FactcheckID)
	if err != nil {
		return shim.Error("Failed to get factcheck: " + err.Error())
	} else if factcheckAsBytes != nil {
		fmt.Println("This factcheck already exists: " + fc.FactcheckID)
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
	ClaimIDratingIndexKey, err1 := stub.CreateCompositeKey(indexRating, []string{fc.ClaimID, fc.Rating_label})
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
	record_type := args[1]

	queryString := fmt.Sprintf("{\"selector\":{\"docType\":\"%s\",\"org\":\"%s\"}}", record_type, org)

	queryResults, err := getQueryResultForQueryString(stub, queryString)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(queryResults)
}

func (t *SimpleChaincode) queryRecords(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//   0
	// "queryString"
	if len(args) < 2 {
		return shim.Error("Incorrect number of arguments. Expecting a search query")
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
