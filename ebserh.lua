local http = require("socket.http")
local ltn12 = require("ltn12")
local socket = require("socket")  -- For sleep functionality

-- List of URLs to check
local urls = {
  "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hu-ufsc",
  "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hu-ufsc?b_start:int=140",
  "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/he-ufpel",
  "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/he-ufpel?b_start:int=60",
  "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hu-furg",
  "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hu-furg?b_start:int=40",
  "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/husm-ufsm",
  "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/husm-ufsm?b_start:int=60",
}

local ultimo_edital = 3928

-- Function to get current timestamp
local function get_timestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

-- Function to extract edital number from link
local function get_edital_number(link)
    local number = string.match(link, "edital%-no%-(%d+)%-")
    if number then
        return tonumber(number)
    end
    return nil
end

-- Function to extract links from HTML content
local function extract_edital_links(html)
    local links = {}
    -- Match both href and src attributes
    for link in html:gmatch('href%s*=%s*["\']([^"\']+)["\']') do
        -- Only add links containing "edital"
        if string.match(string.lower(link), "edital") then
            local number = get_edital_number(link)
            if number and number > ultimo_edital then
                table.insert(links, link)
            end
        end
    end
    for link in html:gmatch('src%s*=%s*["\']([^"\']+)["\']') do
        -- Only add links containing "edital"
        if string.match(string.lower(link), "edital") then
            local number = get_edital_number(link)
            if number and number > 3500 then
                table.insert(links, link)
            end
        end
    end
    return links
end

-- Function to make HTTP request and get content
local function fetch_webpage(url)
    local response = {}

    -- Set up headers to mimic a browser request
    local headers = {
        ["User-Agent"] = "Mozilla/5.0",
        ["Accept"] = "*/*"
    }

    -- Make the HTTP request
    local status, code, headers, status_line = http.request{
        url = url,
        sink = ltn12.sink.table(response),
        headers = headers
    }

    if status == nil then
        error("Failed to make HTTP request: " .. code)
    end

    if code ~= 200 then
        error("HTTP request failed with status code: " .. code)
    end

    return table.concat(response)
end

-- Process a single URL
local function process_url(url)
    print("\nFetching links containing 'edital' with number > ".. ultimo_edital .." from: " .. url)
    print("-------------------------------------------")

    local success, result = pcall(function()
        -- Fetch webpage content
        local content = fetch_webpage(url)

        -- Extract and print links
        local links = extract_edital_links(content)

        if #links == 0 then
            print("No matching links found!")
        else
            print("Found " .. #links .. " matching links:")
            for i, link in ipairs(links) do
                print(i .. ". " .. link)
            end
        end
    end)

    if not success then
        print("Error processing URL: " .. result)
    end
end

-- Function to clear the console (works on both Windows and Unix-like systems)
local function clear_console()
    if package.config:sub(1,1) == '\\' then  -- Windows
        os.execute("cls")
    else  -- Unix-like
        os.execute("clear")
    end
end

-- Main execution
local function main()
    local interval = 20 * 60  -- 20 minutes in seconds
    local iteration = 1

    while true do
        clear_console()
        print("Iteration #" .. iteration .. " - Started at: " .. get_timestamp())
        print("Next check will be in 20 minutes")
        print("=======================================")

        print("Processing " .. #urls .. " URLs")

        for _, url in ipairs(urls) do
            process_url(url)
        end

        print("\nFinished processing all URLs at: " .. get_timestamp())
        print("=======================================")
        print("Waiting 20 minutes before next check...")

        -- Sleep for 20 minutes
        socket.sleep(interval)

        iteration = iteration + 1
    end
end

-- Run the program with error handling
local success, error_msg = pcall(main)
if not success then
    print("Program crashed with error: " .. error_msg)
    print("Press Enter to exit...")
    io.read()
end
