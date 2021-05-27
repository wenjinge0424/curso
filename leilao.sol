/*
SPDX-License-Identifier: CC-BY-4.0
(c) Desenvolvido por Jeff Prestes
This work is licensed under a Creative Commons Attribution 4.0 International License.
*/
pragma solidity 0.8.4;

contract Leilao {

    struct Oferta {
        string nome;
        address payable enderecoCarteira;
        uint valorDaOferta;
        bool jaFoiReembolsado;
    }
    
    address payable public contaGovernamental;
    uint public prazoFinalLeilao;

    address public maiorOfertante;
    uint public maiorLance;

    mapping(address => Oferta) public listaOfertas;
    Oferta[] public ofertas;

    bool public encerrado;

    event novoMaiorLance(address ofertante, uint valor);
    event fimDoLeilao(address arrematante, uint valor);

    modifier somenteGoverno {
        require(msg.sender == contaGovernamental, "Somente Governo pode realizar essa operacao");
        _;
    }

    constructor(
        uint _duracaoLeilao,
        address payable _contaGovernamental
    ) {
        contaGovernamental = _contaGovernamental;
        prazoFinalLeilao = block.timestamp + _duracaoLeilao;
    }


    function lance(string memory nomeOfertante, address payable enderecoCarteiraOfertante) public payable {
        require(block.timestamp <= prazoFinalLeilao, "Leilao encerrado.");
        require(msg.value > maiorLance, "Ja foram apresentados lances maiores.");
        
        maiorOfertante = msg.sender;
        maiorLance = msg.value;
        
        //Realizo estorno das ofertas aos perdedores
        /*
        For é composto por 3 parametros (separados por ponto virgula)
            1o  é o inicializador do indice
            2o  é a condição que será checada para saber se o continua 
                o loop ou não 
            3o  é o incrementador (ou decrementador) do indice
        */
        for (uint i=0; i<ofertas.length; i++) {
            Oferta storage ofertaPerdedora = ofertas[i];
            //   !ofertantePerdedor.jaFoiReembolsado é uma expressão mais curta para checar se a condição é falsa
            //   é o mesmo que escrever ofertantePerdedor.jaFoiReembolsado == false 
            if (!ofertaPerdedora.jaFoiReembolsado) {
                ofertaPerdedora.enderecoCarteira.transfer(ofertaPerdedora.valorDaOferta);
                ofertaPerdedora.jaFoiReembolsado = true;
            }
        }
        
        //Crio o ofertante
        Oferta memory ofertaVencedoraTemporaria = Oferta(nomeOfertante, enderecoCarteiraOfertante, msg.value, false);
        
        //Adiciono o novo concorrente vencedor temporario no array de ofertantes
        ofertas.push(ofertaVencedoraTemporaria);
        
        //Adiciono o novo concorrente vencedor temporario na lista (mapa) de ofertantes
        listaOfertas[ofertaVencedoraTemporaria.enderecoCarteira] = ofertaVencedoraTemporaria;
    
        emit novoMaiorLance (msg.sender, msg.value);
    }

   
    function finalizaLeilao() public somenteGoverno {
       
        require(block.timestamp >= prazoFinalLeilao, "Leilao ainda nao encerrado.");
        //   !encerrado é uma expressão mais curta para checar se a condição é falsa
        //   é o mesmo que escrever encerrado == false 
        require(!encerrado, "Leilao encerrado.");

        encerrado = true;
        emit fimDoLeilao(maiorOfertante, maiorLance);

        contaGovernamental.transfer(address(this).balance);
    }
    
    function retornaMaiorOfertante() public view somenteGoverno returns (address) {
        return maiorOfertante;
    }
}
