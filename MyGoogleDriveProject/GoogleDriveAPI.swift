//
//  GoogleDriveAPI.swift
//  MyGoogleDriveProject
//
//  Created by Nguyen Uy on 17/2/19.
//  Copyright © 2019 Nguyen Uy. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

class GoogleDriveAPI {
    private let service: GTLRDriveService
    
    init(service: GTLRDriveService) {
        self.service = service
    }
    
    public func search(_ name: String, onCompleted: @escaping (GTLRDrive_File?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 1
        query.q = "name contains '\(name)'"
        self.service.executeQuery(query) { (ticket, results, error) in
            onCompleted((results as? GTLRDrive_FileList)?.files?.first, error)
        }
    }
    
    public func listFiles(_ folderID: String, onCompleted: @escaping (GTLRDrive_FileList?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.q = "'\(folderID)' in parents and mimeType != 'application/vnd.google-apps.folder'"
        self.service.executeQuery(query) { (ticket, result, error) in
            onCompleted(result as? GTLRDrive_FileList, error)
        }
    }
    
    public func download(_ fileItem: GTLRDrive_File, onCompleted: @escaping (Data?, Error?) -> ()) {
        guard let fileID = fileItem.identifier else {
            onCompleted(nil, nil)
            return
        }
        
        self.service.executeQuery(GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileID)) { (ticket, file, error) in
            guard let data = (file as? GTLRDataObject)?.data else {
                onCompleted(nil, nil)
                return
            }
            
            onCompleted(data, nil)
        }
    }
    
    private func upload(_ folderID: String, path: String, MIMEType: String, onCompleted: ((String?, Error?) -> ())?) {
        guard let data = FileManager.default.contents(atPath: path) else {
            onCompleted?(nil, NSError(domain: "GoogleDrive", code: 0, userInfo: ["message": "No data at path"]))
            return
        }
        
        let file = GTLRDrive_File()
        file.name = path.components(separatedBy: "/").last
        file.parents = [folderID]
        
        let uploadParams = GTLRUploadParameters.init(data: data, mimeType: MIMEType)
        uploadParams.shouldUploadWithSingleRequest = true
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParams)
        query.fields = "id"
        
        self.service.executeQuery(query, completionHandler: { (ticket, file, error) in
            onCompleted?((file as? GTLRDrive_File)?.identifier, error)
        })
    }
    
    public func delete(_ fileItem: GTLRDrive_File, onCompleted: @escaping ((Error?) -> ())) {
        guard let fileID = fileItem.identifier else {
            onCompleted(nil)
            return
        }
        
        self.service.executeQuery(GTLRDriveQuery_FilesDelete.query(withFileId: fileID)) { (ticket, nilFile, error) in
            onCompleted(error)
        }
    }
}
