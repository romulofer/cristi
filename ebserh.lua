local http = require("socket.http")
local ltn12 = require("ltn12")
local socket = require("socket") -- For sleep functionality

local ultimo_edital = 4417
local ano_especial = 2025
local limite_ano_especial = 508

-- List of URLs to check
local urls = {
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hu-ufsc",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hu-ufsc?b_start:int=180",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/he-ufpel",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/he-ufpel?b_start:int=60",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hu-furg",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/hu-furg?b_start:int=60",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/husm-ufsm",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/husm-ufsm?b_start:int=60",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/chc-ufpr",
    "https://www.gov.br/ebserh/pt-br/acesso-a-informacao/agentes-publicos/concursos-e-selecoes/concursos/2023/concurso-no-01-2023-ebserh-nacional/convocacoes/chc-ufpr?b_start:int=180"
}

-- ANSI escape codes for colors
local colors = {
    reset = "\27[0m",
    red = "\27[31m",
    green = "\27[32m",
    yellow = "\27[33m",
    blue = "\27[34m",
    magenta = "\27[35m",
    cyan = "\27[36m",
    white = "\27[37m"
}

-- Function to get current timestamp
local function get_timestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

-- Function to extract edital number from link
local function get_edital_number(link)
    -- Padrão para capturar o número no formato "número-ano"
    local number = string.match(link, "edital%-no%-(%d+%-%d+)%-")
    if number then
        -- Extrai o número e o ano
        local numero_edital, ano = string.match(number, "^(%d+)%-(%d+)$")
        return tonumber(numero_edital), tonumber(ano)
    end
    return nil, nil
end

-- Function to extract links from HTML content
local function extract_edital_links(html)
    local links = {}
    for link in html:gmatch('href%s*=%s*["\']([^"\']+)["\']') do
        if string.match(string.lower(link), "edital") then
            local numero_edital, ano = get_edital_number(link)
            if numero_edital then
                -- Verifica se o ano é 2025 e ajusta o limite de comparação
                local limite = (ano == ano_especial) and limite_ano_especial or ultimo_edital
                if numero_edital > limite then
                    table.insert(links, { link = link, number = numero_edital, ano = ano })
                end
            end
        end
    end
    return links
end

-- Function to make HTTP request and get content
local function fetch_webpage(url)
    local response = {}

    local headers = {
        ["User-Agent"] = "Mozilla/5.0",
        ["Accept"] = "*/*"
    }

    local status, code = http.request {
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
    print(colors.cyan .. "\nFetching links containing 'edital' from: " .. url .. colors.reset)
    print(colors.yellow .. "-------------------------------------------" .. colors.reset)

    local success, result = pcall(function()
        local content = fetch_webpage(url)
        local links = extract_edital_links(content)

        if #links == 0 then
            print(colors.red .. "No matching links found!" .. colors.reset)
        else
            print(colors.green .. "Found " .. #links .. " matching links:" .. colors.reset)
            for i, link_info in ipairs(links) do
                print(colors.blue ..
                    i ..
                    ". " ..
                    link_info.link ..
                    " (Number: " .. link_info.number .. ", Year: " .. link_info.ano .. ")" .. colors.reset)
            end
        end
    end)

    if not success then
        print(colors.red .. "Error processing URL: " .. result .. colors.reset)
    end
end

-- Function to clear the console
local function clear_console()
    if package.config:sub(1, 1) == '\\' then
        os.execute("cls")
    else
        os.execute("clear")
    end
end

-- Main execution
local function main()
    local interval = 20 * 60
    local iteration = 1

    while true do
        clear_console()
        print(colors.magenta .. "Iteration #" .. iteration .. " - Started at: " .. get_timestamp() .. colors.reset)
        print(colors.yellow .. "Next check will be in 20 minutes" .. colors.reset)
        print(colors.cyan .. "=======================================" .. colors.reset)

        print(colors.white .. "Processing " .. #urls .. " URLs" .. colors.reset)

        for _, url in ipairs(urls) do
            process_url(url)
        end

        print(colors.green .. "\nFinished processing all URLs at: " .. get_timestamp() .. colors.reset)
        print(colors.cyan .. "=======================================" .. colors.reset)
        print(colors.yellow .. "Waiting 20 minutes before next check..." .. colors.reset)

        socket.sleep(interval)
        iteration = iteration + 1
    end
end

-- Run the program with error handling
local success, error_msg = pcall(main)
if not success then
    print(colors.red .. "Program crashed with error: " .. error_msg .. colors.reset)
    print(colors.yellow .. "Press Enter to exit..." .. colors.reset)
    io.read()
end
