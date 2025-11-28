function answer = ask(prompt_text)
    // ========================================================
    // 1. CONFIGURATION
    // ========================================================
    dq = ascii(34); // Double Quote (")
    sq = ascii(39); // Single Quote (')
    bs = ascii(92); // Backslash (\)
    
    // API KEY
    api_key = "YOUR-API-KEY";
    
    // MODEL: gemini-2.5-flash (Fast & Valid for your key)
    model = "gemini-2.5-flash"; 
    
    // ========================================================
    // 2. PREPARE PAYLOAD (File Method)
    // ========================================================
    temp_file = TMPDIR + "\gemini_payload.json";
    
    // Clean Prompt: Replace double quotes with single quotes for safety
    clean_prompt = strsubst(prompt_text, dq, sq);
    // Escape backslashes to prevent JSON errors
    clean_prompt = strsubst(clean_prompt, bs, bs+bs);
    
    // JSON Structure
    part1 = "{" + dq + "contents" + dq + ":[{" + dq + "parts" + dq + ":[{" + dq + "text" + dq + ":" + dq;
    part2 = clean_prompt;
    part3 = dq + "}]}]}";
    
    fd = mopen(temp_file, "wt");
    mputl(part1 + part2 + part3, fd);
    mclose(fd);
    
    // ========================================================
    // 3. SEND REQUEST
    // ========================================================
    url = "https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent?key=" + api_key;
    
    // Flags: -k (No SSL), -s (Silent), -d @file (Data), 2>&1 (Capture Errors)
    cmd = "curl -k -s -H " + dq + "Content-Type: application/json" + dq + " -d @" + dq + temp_file + dq + " " + dq + url + dq + " 2>&1";
    
    try
        response_lines = unix_g(cmd);
        full_response = strcat(response_lines, " ");
        
        // ====================================================
        // 4. PARSE RESPONSE (The New "Walker" Method)
        // ====================================================
        // We find the start of the text and walk until the valid end quote.
        
        // 1. Find "text": "
        key_pattern = dq + "text" + dq + ": " + dq; // try with space
        k_idx = strindex(full_response, key_pattern);
        
        // If not found, try without space
        if k_idx == [] then
            key_pattern = dq + "text" + dq + ":" + dq;
            k_idx = strindex(full_response, key_pattern);
        end
        
        if k_idx <> [] then
            // Start reading AFTER the opening quote
            start_pos = k_idx(1) + length(key_pattern);
            current_pos = start_pos;
            len = length(full_response);
            
            // 2. Walk the string to find the closing quote
            // We must ignore escaped quotes (\")
            is_escaped = %f;
            
            while current_pos <= len
                char_now = part(full_response, current_pos);
                
                if is_escaped then
                    is_escaped = %f; // This char was escaped, move on
                else
                    if char_now == bs then
                        is_escaped = %t; // Next char is escaped
                    elseif char_now == dq then
                        break; // Found the REAL closing quote
                    end
                end
                current_pos = current_pos + 1;
            end
            
            // 3. Extract the clean content
            raw_content = part(full_response, start_pos : current_pos - 1);
            
            // 4. Decode JSON escapes
            // Order matters: Unescape backslashes last to avoid confusion
            clean_ans = strsubst(raw_content, bs + "n", ascii(10)); // \n -> Newline
            clean_ans = strsubst(clean_ans, bs + dq, dq);           // \" -> "
            clean_ans = strsubst(clean_ans, bs + bs, bs);           // \\ -> \
            
            // =================================================
            // 5. PRINT UI
            // =================================================
            disp(" ");
            disp("==========================================================");
            disp(" GEMINI (" + model + ") ANSWERED:");
            disp("==========================================================");
            disp(" ");
            disp(clean_ans);
            disp(" ");
            disp("==========================================================");
            
            answer = clean_ans;
        else
             // Check for Errors
             if strindex(full_response, "error") <> [] then
                 disp("!!! API ERROR !!!");
                 disp(full_response);
             else
                 disp("!!! PARSE ERROR !!!");
                 disp("Could not find text field. Raw response:");
                 disp(full_response);
             end
             answer = "";
        end
        
    catch
        disp("System Error:");
        disp(lasterror());
        answer = "";
    end
    
    mdelete(temp_file);
endfunction
