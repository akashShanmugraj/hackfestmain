from flask import Flask
from algorithm import System, Path, Node, PathComputationObject
from flask import request,jsonify
from services import DatabaseObject, ChromaDBAgent
import json
from pprint import pprint
from typing import List

def read_json_file(file_path):
    with open(file_path, "r") as file:
        data = json.load(file)
    return data

computepathobject = PathComputationObject()
centralsystemobject = System(distancelimit=5)
# databaseobject = DatabaseObject()
# chromadbagent = ChromaDBAgent()
masterpathlist: List[Path] = list()
centralsystemobject.addrequest(Node(x_pos=40.646984, y_pos=-73.789450, item="Flashlight", quantity=1))
centralsystemobject.addrequest(Node(x_pos=42.646984, y_pos=-73.789450, item="Flashlight", quantity=-1))

app = Flask(__name__)


@app.route("/")
def home():
    return "this API will be used to natively interact with the algorithm logic"


# @app.route("/add/node", methods=["POST"])
# def addrequest():
#     body = request.get_json()
#     '''
#     new body format
#     {
#         "nodelist": [
#             {
#                 "xposition": 1,
#                 "yposition": 1,
#                 "itemid": "Flashlight",
#                 "quantity": 1,
#                 "username": "JohnDoe"
#             },
#             {
#                 "xposition": 1,
#                 "yposition": 1,
#                 "itemid": "Flashlight",
#                 "quantity": -1,
#                 "username": "JohnDoe"
#             }
#         ]
#     }
#     '''
#     for node in body["nodelist"]:
#         newnode = Node(
#             x_pos=node["xposition"],
#             y_pos=node["yposition"],
#             item=node["itemid"],
#             quantity=node["quantity"],
#         )
#         updatedcluster = centralsystemobject.addrequest(newnode)
    
#         databaseobject.insertrequest(
#             requestid=newnode.identifier,
#             resourceid=node["itemid"],
#             clusterid=updatedcluster.identifier,
#             username=node["username"],
#             quantity=node["quantity"],
#             newlat=updatedcluster.centerxpos,
#             newlon=updatedcluster.centerxpos,
#         )
#     computepathobject.setSystem(centralsystemobject)

#     masterpathlist = computepathobject.getPaths()
    
#     # print("Before clearing", chromadbagent.numberofvectors())
    
#     # chromadbagent.clearindex()
#     databaseobject.truncatepath()
#     # print("After clearing", chromadbagent.numberofvectors())
    
    
#     for path in masterpathlist:
#         if not path:
#             continue
#         print("\n")
#         databaseobject.insertpath(path.identifier, path.constructdatabaseobject())
#         # chromadbagent.insertpathobject(path.identifier, [path.xposition, path.yposition])
#         print("\n")
    
    
#     return centralsystemobject.stats()

@app.route("/sample/paths", methods=["POST"])
def getpaths():
    body = request.get_json()
    return read_json_file("samplepaths.json")


# @app.route("/get/paths", methods=["POST"])
# def getactualpaths():
#     body = request.get_json()

#     nearestids = chromadbagent.getnearestneighbors([body["xposition"], body["yposition"]])
#     nearestpaths: List[Path] = list()
#     if len(nearestids) == 0:
#         return {
#             "message": "No paths returned from the database"
#         }
    
#     masterpathlist = computepathobject.getPaths()
#     if not masterpathlist:
#         return {
#             "message": "No paths in the masterpathlist"
#         }

#     for path in masterpathlist:
#         if path and path.identifier in nearestids[0]:
#             nearestpaths.append(path)
    
#     if len(nearestpaths) == 0:
#         return {
#             "message": "No paths matched the nearest neighbors"
#         }
#     exportlist = []
    
#     for path in nearestpaths:
#         exportlist.append(path.constructdatabaseobject())
    
#     return computepathobject.formatpathoutput(exportlist)


@app.route("/get/stats")
def stats():
    return centralsystemobject.stats()

# @app.route("/get/db/stats", methods=["GET"])
# def dbstats():
#     return chromadbagent.getallvectors()


if __name__ == "__main__":
    app.run(port=4160)
